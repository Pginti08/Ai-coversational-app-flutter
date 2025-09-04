import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/utils/validators.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString countryCode = '+91'.obs;
  final TextEditingController mobileNoController = TextEditingController();
  final RxString mobileError = ''.obs;

  void validateAndLogin() {
    final error = validateMobileNumber(mobileNoController.text.trim(), 10, 10);
    mobileError.value = error ?? '';

    if (error == null) {
      loginApi(mobileNoController.text.trim());
    }
  }

  Future<void> loginApi(String mobileNumber) async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.signIn}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "phone": mobileNumber,
            "code": countryCode.value,
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
