import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/validators.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/routes/app_pages.dart';

class SignupController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString countryCode = '+91'.obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();

  final RxString nameError = ''.obs;
  final RxString mobileError = ''.obs;

  bool fromInvitePost = false;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["fromInvitePost"] != null) {
      fromInvitePost = Get.arguments["fromInvitePost"];
    }
    super.onInit();
  }

  void validateAndSignUp() {
    final error1 = validateCommonField(nameController.text.trim(), "name");

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
            "fromInvitePost": fromInvitePost,
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
