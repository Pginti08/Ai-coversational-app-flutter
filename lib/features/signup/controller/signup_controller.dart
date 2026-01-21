import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/deep_link_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/validators.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/routes/app_pages.dart';

class SignupController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString countryCode = '+91'.obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  final RxString nameError = ''.obs;
  final RxString mobileError = ''.obs;

  final RxBool hasPrefilledReferralCode = false.obs;

  @override
  void onInit() {
    // Get referral code from deep link arguments
    if (Get.arguments != null && Get.arguments["referralCode"] != null) {
      final code = Get.arguments["referralCode"];
      if (code != null && code.isNotEmpty) {
        referralCodeController.text = code;
      }
    }
    // Fallback: check pending referral code from storage
    _loadPendingReferralCode();
    super.onInit();
  }

  Future<void> _loadPendingReferralCode() async {
    // Only load if no referral code is already set
    if (referralCodeController.text.isEmpty) {
      try {
        final deepLinkHandler = Get.find<DeepLinkHandler>();
        final pendingCode = await deepLinkHandler.getPendingReferralCode();
        if (pendingCode != null && pendingCode.isNotEmpty) {
          referralCodeController.text = pendingCode;
          hasPrefilledReferralCode.value = true;
        }
      } catch (e) {
        print('❌ Error loading pending referral code: $e');
      }
    }
  }

  void validateAndSignUp() {
    String? error1;
    if (nameController.text.trim().isEmpty) {
      error1 = 'please enter a name';
    }

    final error2 = validateMobileNumber(mobileNoController.text.trim(), 10, 10);
    nameError.value = error1 ?? '';
    mobileError.value = error2 ?? '';

    if (error1 == null && error2 == null) {
      signUpApi(mobileNoController.text.trim());
    }
  }

  Future<void> signUpApi(String mobileNumber) async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.signUp}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "name": nameController.text.trim(),
            "phone": mobileNumber,
            "code": countryCode.value,
            if (isNotNullOrEmpty(referralCodeController.text.trim()))
              "referralCode": referralCodeController.text.trim(),
          });

      if (result.isSuccess) {
        Get.toNamed(Routes.otpVerify, arguments: {
          "mobileNo": mobileNumber,
          "countryCode": countryCode.value
        });
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
