import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/otp-verify/models/verify_otp_model.dart';
import 'package:vousvous/routes/app_pages.dart';

class OtpVerifyController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isOtpVerified = false.obs;

  final RxString mobileNo = "".obs;
  final RxString countryCode = "".obs;

  TextEditingController otpController = TextEditingController();
  Rx<String?> otpError = Rx<String?>(null);

  late Timer timer;
  int start = 60;
  RxInt secondsRemaining = 60.obs;
  RxBool isButtonEnabled = false.obs;

  @override
  void onInit() {
    startResendTimer();
    if (Get.arguments != null) {
      if (Get.arguments["mobileNo"] != null) {
        mobileNo.value = Get.arguments["mobileNo"];
      }
      if (Get.arguments["countryCode"] != null) {
        countryCode.value = Get.arguments["countryCode"];
      }
    }
    super.onInit();
  }

  void startResendTimer() {
    start = 60;
    secondsRemaining.value = start;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start == 0) {
        timer.cancel();
      } else {
        start--;
        secondsRemaining.value = start;
      }
    });
  }

  Future<void> verifyOtpApi() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.verifyOtp}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "phone": mobileNo.value,
            "code": countryCode.value,
            "otp": otpController.text.trim()
          });

      if (result.isSuccess) {
        isOtpVerified.value = true;
        var verifyOtpModel = VerifyOtpModel.fromJson(result.data?.data);
        await LocalStorageService.instance.saveString(
          StorageConstants.accessToken,
          verifyOtpModel.data?.token ?? "",
        );

        Future.delayed(Duration(milliseconds: 1500), () {
          Get.offAllNamed(Routes.home);
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

  Future<void> resendOtpApi() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.resendOtp}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "phone": mobileNo.value,
            "code": countryCode.value,
          });

      if (result.isSuccess) {
        toast(result.error.toString());
        startResendTimer();
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
