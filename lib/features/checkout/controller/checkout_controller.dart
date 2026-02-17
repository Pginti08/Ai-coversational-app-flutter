import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:vousvous/features/saved-address/models/saved_address_model.dart';
import 'package:vousvous/features/wallet/controller/wallet_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class CheckoutController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  // Shipping address selection
  Rxn<SavedAddress> selectedAddress = Rxn<SavedAddress>();

  // Billing address selection
  Rxn<SavedAddress> selectedBillingAddress = Rxn<SavedAddress>();
  final RxBool billingSameAsShipping = true.obs;

  final Rx<SavedAddressModel> savedAddressModel = SavedAddressModel().obs;

  String? quotationCardId;
  CardDetail? quotation;

  // Wallet balance
  final RxDouble walletBalance = 0.0.obs;
  final RxBool isLoadingBalance = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if this is a quotation checkout
    final args = Get.arguments;
    if (args != null && args is Map) {
      quotationCardId = args['quotationCardId'];
      quotation = args['quotation'];
    }
    getSavedAddress();
    refreshWalletBalance();
  }

  Future<void> getSavedAddress() async {
    selectedAddress.value = null;
    selectedBillingAddress.value = null;
    try {
      isLoading.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.addresses}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        savedAddressModel.value = SavedAddressModel.fromJson(result.data?.data);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh wallet balance from WalletController or fetch directly
  Future<void> refreshWalletBalance() async {
    isLoadingBalance.value = true;

    // Try to get from WalletController first
    if (Get.isRegistered<WalletController>()) {
      final walletController = Get.find<WalletController>();
      await walletController.fetchWalletBalance();
      walletBalance.value =
          walletController.walletBalance.value?.balanceCU ?? 0.0;
    } else {
      // Fetch directly if WalletController not registered
      final result = await NetworkClient.instance.callApi(
        ApiConstants.walletBalance,
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess && result.data != null) {
        try {
          final data = result.data!.data;
          debugPrint('Wallet balance API response: $data');
          if (data['success'] == true && data['data'] != null) {
            walletBalance.value =
                (data['data']['balanceCU'] as num?)?.toDouble() ?? 0.0;
          }
        } catch (e) {
          debugPrint('Error parsing wallet balance: $e');
        }
      }
    }

    isLoadingBalance.value = false;
  }

  void selectShippingAddress(SavedAddress? address) {
    selectedAddress.value = address;
    // If billing same as shipping, also update billing address
    if (billingSameAsShipping.value) {
      selectedBillingAddress.value = address;
    }
  }

  void selectBillingAddress(SavedAddress? address) {
    selectedBillingAddress.value = address;
  }

  void toggleBillingSameAsShipping(bool value) {
    billingSameAsShipping.value = value;
    if (value) {
      selectedBillingAddress.value = selectedAddress.value;
    } else {
      selectedBillingAddress.value = null;
    }
  }

  /// Calculate total amount for quotation
  double get quotationTotalAmount {
    if (quotation == null) return 0;
    final price = quotation?.price?.toDouble() ?? 0.0;
    final quantityStr = quotation?.quantity ?? "1";
    final quantity = double.tryParse(quantityStr) ?? 1.0;
    return price * quantity;
  }

  /// Get quantity as int for display
  int get quotationQuantity {
    final quantityStr = quotation?.quantity ?? "1";
    return int.tryParse(quantityStr) ?? 1;
  }

  /// Calculate total credits needed (1 credit = ₹100)
  double get creditsNeeded {
    return quotationTotalAmount / 100;
  }

  /// 50% upfront amount in INR
  double get upfrontAmount {
    return quotationTotalAmount / 2;
  }

  /// 50% remaining amount in INR (paid at delivery)
  double get remainingAmount {
    return quotationTotalAmount - upfrontAmount;
  }

  /// Credits needed for 50% upfront payment
  double get upfrontCredits {
    return upfrontAmount / 100;
  }

  /// Check if wallet has sufficient balance for 50% upfront
  bool get hasSufficientBalance {
    return walletBalance.value >= upfrontCredits;
  }

  /// Get the deficit amount (credits needed to add for 50% upfront)
  double get creditsDeficit {
    final deficit = upfrontCredits - walletBalance.value;
    return deficit > 0 ? deficit : 0;
  }

  /// Navigate to buy credits with prefilled amount
  void navigateToBuyCredits() {
    Get.toNamed(Routes.buyCredit, arguments: {
      'prefilledCredits': creditsDeficit.toStringAsFixed(2),
      'returnToCheckout': true,
      'checkoutArguments': {
        'quotationCardId': quotationCardId,
        'quotation': quotation,
      },
    });
  }

  Future<void> placeOrderApi() async {
    await _placeQuotationOrder();
  }

  Future<void> _placeQuotationOrder() async {
    // Validation
    if (selectedAddress.value == null) {
      toast("Please select a shipping address", type: ToastType.warning);
      return;
    }

    final billingAddress = billingSameAsShipping.value
        ? selectedAddress.value
        : selectedBillingAddress.value;

    if (billingAddress == null) {
      toast("Please select a billing address", type: ToastType.warning);
      return;
    }

    if (quotationCardId == null || quotationCardId!.isEmpty) {
      toast("Invalid quotation", type: ToastType.error);
      return;
    }

    // Check wallet balance
    if (!hasSufficientBalance) {
      toast("Insufficient credits. Please add credits to continue.",
          type: ToastType.warning);
      return;
    }

    try {
      isLoading2.value = true;

      final payload = {
        "quotationCardId": quotationCardId,
        "addressId": selectedAddress.value?.id,
        "billingAddressId": billingAddress.id,
        "paymentMode": "WALLET",
        "unitPrice": quotation?.price ?? 0,
        "totalAmount": quotationTotalAmount,
        "paidAmountINR": 0,
        "paidCoinsCU": upfrontCredits,
      };

      debugPrint('Placing quotation order with payload: $payload');

      var result = await NetworkClient.instance.callApi(
        ApiConstants.orders,
        MethodType.post,
        baseUrlType: BaseUrl.base,
        params: payload,
      );

      if (result.isSuccess) {
        toast("Order placed successfully!", type: ToastType.success);

        // Refresh wallet balance if controller exists
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().refreshAll();
        }

        Get.until((route) => Get.currentRoute == Routes.home);
        Get.toNamed(Routes.orders);
      } else {
        toast(result.error ?? "Failed to place order", type: ToastType.error);
      }
    } catch (e) {
      debugPrint('Error placing quotation order: $e');
      toast(e.toString(), type: ToastType.error);
    } finally {
      isLoading2.value = false;
    }
  }
}
