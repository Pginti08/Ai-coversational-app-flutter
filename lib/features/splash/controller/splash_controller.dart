import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/deep_link_service.dart'; // Ensure this path is correct
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/routes/app_pages.dart';
// In splash_controller.dart

class SplashController extends GetxController {
  void _navigateBasedOnAuth() {
    // 1. Perform the default navigation away from the Splash screen
    final targetRoute = isNotNullOrEmpty(LocalStorageService.instance
            .getString(StorageConstants.accessToken))
        ? Routes.home
        : Routes.welcome;

    // Use Get.offNamed to move to the default screen
    Get.offNamed(targetRoute);

    // 2. Schedule the deep link check to run AFTER the home/welcome screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Post-frame callback: Checking for delayed deep link.");
      final DeepLinkHandler deepLinkHandler = Get.find<DeepLinkHandler>();

      // If a pending link exists, this will perform the final redirect
      // (e.g., Get.toNamed(Routes.sharePreview) or Get.offAllNamed(Routes.signup))
      // overriding the current Home/Welcome screen.
      deepLinkHandler.processDelayedDeepLink();
    });
  }

  @override
  void onInit() {
    // Always wait for the 2800ms
    Future.delayed(Duration(milliseconds: 2800), () {
      _navigateBasedOnAuth();
    });
    super.onInit();
  }
}
