import 'dart:async';

import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerifyController extends GetxController {
  final isOtpVerified = false.obs;
  TextEditingController otpController = TextEditingController();
  Rx<String?> otpError = Rx<String?>(null);

  late Timer timer;
  int start = 60;
  RxInt secondsRemaining = 60.obs;
  RxBool isButtonEnabled = false.obs;

  @override
  void onInit() {
    startResendTimer();
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

  void verifyOtp() {
    // Normally you would call API here, then:
    isOtpVerified.value = true;
    Future.delayed(Duration(milliseconds: 1500), () {
      Get.offAllNamed(Routes.home);
    });
  }
}
