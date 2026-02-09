import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/checkout/controller/checkout_controller.dart';
import 'package:vousvous/features/wallet/controller/wallet_controller.dart';
import 'package:vousvous/features/wallet/models/coin_order_model.dart';

class BuyCreditController extends GetxController {
  final TextEditingController creditController = TextEditingController();
  final RxDouble enteredCredits = 0.0.obs;
  final RxDouble payableAmount = 0.0.obs;
  final RxBool isLoading = false.obs;

  late Razorpay _razorpay;

  // Conversion rate: 0.01 credits = ₹1, so 1 credit = ₹100
  static const double creditToRupeeMultiplier = 100.0;

  // Flag to indicate if we should return to checkout after successful payment
  bool returnToCheckout = false;
  Map<String, dynamic>? checkoutArguments;

  @override
  void onInit() {
    super.onInit();

    // Check for prefilled credits from arguments
    final args = Get.arguments;
    if (args != null && args is Map) {
      final prefilledCredits = args['prefilledCredits'];
      if (prefilledCredits != null) {
        creditController.text = prefilledCredits.toString();
      }
      returnToCheckout = args['returnToCheckout'] ?? false;
      checkoutArguments = args['checkoutArguments'];
    }

    creditController.addListener(_onCreditChanged);
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _onCreditChanged() {
    final text = creditController.text.trim();
    if (text.isEmpty) {
      enteredCredits.value = 0.0;
      payableAmount.value = 0.0;
      return;
    }

    // Parse the credit value (max 2 decimal places allowed)
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0) {
      enteredCredits.value = parsed;
      payableAmount.value = parsed * creditToRupeeMultiplier;
    }
  }

  /// Validates and formats input to max 2 decimal places
  String? validateCreditInput(String value) {
    if (value.isEmpty) return null;

    // Check if valid number
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return "Enter a valid number";
    }

    // Check for negative
    if (parsed < 0) {
      return "Credits cannot be negative";
    }

    // Check decimal places
    if (value.contains('.')) {
      final parts = value.split('.');
      if (parts.length > 1 && parts[1].length > 2) {
        return "Max 2 decimal places allowed";
      }
    }

    return null;
  }

  void onPayNow() async {
    if (enteredCredits.value <= 0) {
      toast("Please enter credits to purchase", type: ToastType.warning);
      return;
    }

    if (payableAmount.value <= 0) {
      toast("Invalid amount", type: ToastType.error);
      return;
    }

    isLoading.value = true;

    // First call coin-order API
    final coinOrderData = await _createCoinOrder();

    if (coinOrderData != null) {
      // Only open Razorpay if coin order was successful
      _openRazorpayCheckout(coinOrderData);
    } else {
      isLoading.value = false;
    }
  }

  Future<CoinOrderData?> _createCoinOrder() async {
    final result = await NetworkClient.instance.callApi(
      ApiConstants.coinOrder,
      MethodType.post,
      baseUrlType: BaseUrl.base,
      params: {
        'amountINR': payableAmount.value.toInt(),
        'coinsCU': enteredCredits.value,
      },
    );

    if (result.isSuccess && result.data != null) {
      try {
        final model = CoinOrderModel.fromJson(result.data!.data);
        if (model.success == true && model.data != null) {
          debugPrint('Coin order created successfully');
          return model.data;
        } else {
          toast(model.message ?? "Failed to create order",
              type: ToastType.error);
          return null;
        }
      } catch (e) {
        debugPrint('Error parsing coin order: $e');
        toast("Failed to create order", type: ToastType.error);
        return null;
      }
    } else {
      toast(result.error ?? "Failed to create order", type: ToastType.error);
      return null;
    }
  }

  void _openRazorpayCheckout(CoinOrderData coinOrderData) {
    // Get user details from local storage
    final userData = LocalStorageService.instance.userInfo.value.data;
    final String userName = userData?.name ?? "Customer";
    final String userEmail = ""; // Email not available in user model
    final String userPhone = userData?.phone ?? "";

    // Use data from API response
    final String razorpayKeyId = coinOrderData.razorpayKeyId ?? '';
    final String orderId = coinOrderData.order?.razorpayOrderId ?? '';
    final int amountPaise = coinOrderData.order?.amountPaise ?? 0;
    final double credits = coinOrderData.order?.coinsCU ?? enteredCredits.value;

    var options = {
      'key': razorpayKeyId,
      'amount': amountPaise,
      'order_id': orderId,
      'name': 'Vousvous',
      'description': 'Buy $credits Credits',
      'image':
          'https://vrozart-fashion-app-prod.s3.ap-south-1.amazonaws.com/logo/vousvous.jpeg',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#68C3E7',
      },
      'notes': {
        'credits': credits.toString(),
        'user_id': userData?.id ?? '',
        'order_id': coinOrderData.order?.id ?? '',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error opening Razorpay: $e');
      toast("Error opening payment gateway", type: ToastType.error);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');

    // Verify payment with backend
    final verified = await _verifyPayment(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );

    isLoading.value = false;

    if (verified) {
      toast("Payment successful! Credits added to your wallet.",
          type: ToastType.success);

      // Clear the input after successful payment
      creditController.clear();
      enteredCredits.value = 0.0;
      payableAmount.value = 0.0;

      // Refresh wallet balance
      _refreshWalletBalance();

      // Navigate back - either to checkout or previous screen
      if (returnToCheckout && checkoutArguments != null) {
        Get.back(); // Close buy credit screen
        // Refresh checkout controller's wallet balance
        if (Get.isRegistered<CheckoutController>()) {
          Get.find<CheckoutController>().refreshWalletBalance();
        }
      } else {
        Get.back();
      }
    } else {
      toast("Payment verification failed. Please contact support.",
          type: ToastType.error);
    }
  }

  Future<bool> _verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final result = await NetworkClient.instance.callApi(
      ApiConstants.verifyPayment,
      MethodType.post,
      baseUrlType: BaseUrl.base,
      params: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );

    if (result.isSuccess && result.data != null) {
      final data = result.data!.data;
      if (data['success'] == true) {
        debugPrint('Payment verified successfully');
        return true;
      } else {
        debugPrint('Payment verification failed: ${data['message']}');
        return false;
      }
    } else {
      debugPrint('Payment verification error: ${result.error}');
      return false;
    }
  }

  void _refreshWalletBalance() {
    // Check if WalletController is registered and refresh balance
    if (Get.isRegistered<WalletController>()) {
      Get.find<WalletController>().fetchWalletBalance();
      Get.find<WalletController>().fetchHistory();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isLoading.value = false;
    debugPrint('Payment Error: ${response.code} - ${response.message}');

    String errorMessage = "Payment failed";
    if (response.message != null) {
      errorMessage = response.message!;
    }

    toast(errorMessage, type: ToastType.error);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isLoading.value = false;
    debugPrint('External Wallet: ${response.walletName}');
    toast("External wallet selected: ${response.walletName}",
        type: ToastType.general);
  }

  @override
  void onClose() {
    creditController.removeListener(_onCreditChanged);
    creditController.dispose();
    _razorpay.clear();
    super.onClose();
  }
}
