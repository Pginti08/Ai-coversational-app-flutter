import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/validators.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InviteFriendController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString mobileError = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void validateAndInviteFriend() {
    final error1 = validateCommonField(nameController.text.trim(), "name");
    final error2 = validateMobileNumber(mobileNoController.text.trim(), 10, 10);

    final error3 = isNotNullOrEmpty(emailController.text.trim())
        ? validateEmail(emailController.text.trim())
        : null;
    nameError.value = error1 ?? '';
    mobileError.value = error2 ?? '';
    emailError.value = error3 ?? '';

    if (error1 == null && error2 == null && error3 == null) {
      inviteFriendApi();
    }
  }

  Future<void> inviteFriendApi() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.inviteFriend}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "name": nameController.text.trim(),
            "phone": mobileNoController.text.trim(),
            "code": "+91",
            "email": emailController.text.trim(),
          });
      if (result.isSuccess) {
        toast("Invitation sent successfully!", type: ToastType.success);
        Get.back();
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
