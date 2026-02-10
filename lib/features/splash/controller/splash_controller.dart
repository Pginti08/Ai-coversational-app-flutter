import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/deep_link_service.dart';
import 'package:vousvous/core/services/install_referrer_service.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/routes/app_pages.dart';

class SplashController extends GetxController {
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for splash animation first
    await Future.delayed(const Duration(milliseconds: 2800));

    // Prevent double navigation
    if (_hasNavigated) {
      print('ℹ️ Navigation already performed, skipping');
      return;
    }
    _hasNavigated = true;

    final deepLinkHandler = Get.find<DeepLinkHandler>();

    // Check if user has a stored token
    final hasToken = isNotNullOrEmpty(
      LocalStorageService.instance.getString(StorageConstants.accessToken),
    );
    print('🔐 Has stored token: $hasToken');

    // Ensure install referrer has been checked before reading the referral code
    // initDeepLinks() is not awaited in App.initState(), so we explicitly await here
    if (Platform.isAndroid) {
      await InstallReferrerHandler.checkAndStoreReferralCode();
    }

    // Get pending referral code (from Play Store install referrer or deep link)
    final pendingReferralCode = await deepLinkHandler.getPendingReferralCode();
    print('📋 Pending referral code: $pendingReferralCode');

    if (hasToken) {
      // Token exists — validate it before navigating to home
      // This prevents stale tokens (e.g. restored by Android Auto Backup) from
      // sending the user to Home only to get kicked to Login immediately.
      print('👤 Token found, validating...');

      final isTokenValid = await _validateToken();

      if (isTokenValid) {
        print('✅ Token is valid, navigating to home');
        Get.offAllNamed(Routes.home);

        // Process delayed deep link AFTER navigation to home
        await Future.delayed(const Duration(milliseconds: 300));
        deepLinkHandler.processDelayedDeepLink();

        print('✅ Navigated to home and processed pending deep links');

        // Mark initial launch as complete
        deepLinkHandler.markInitialLaunchComplete();
        return;
      } else {
        // Token is expired/invalid — clear storage and treat as new user
        print('⚠️ Token is invalid/expired, clearing storage');
        await LocalStorageService.instance.clear();
        // Fall through to the not-logged-in flow below
      }
    }

    // USER IS NOT LOGGED IN (or token was invalid)
    print('👤 User is not logged in');

    if (isNotNullOrEmpty(pendingReferralCode)) {
      // Has referral code - navigate to signup with prefilled code
      print('🎯 Found pending referral code: $pendingReferralCode');
      print('➡️ Navigating to signup with prefilled referral code');

      Get.offAllNamed(Routes.signup, arguments: {
        "referralCode": pendingReferralCode,
      });
    } else {
      // Check if there's a pending deep link that might have referral code
      // This handles the case where deep link was captured but referral not yet stored
      deepLinkHandler.processDelayedDeepLink();

      // Small delay to allow deep link processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Re-check for referral code after processing
      final codeAfterProcessing =
          await deepLinkHandler.getPendingReferralCode();

      if (isNotNullOrEmpty(codeAfterProcessing)) {
        print('🎯 Found referral code after deep link processing');
        Get.offAllNamed(Routes.signup, arguments: {
          "referralCode": codeAfterProcessing,
        });
      } else {
        // No referral code - go to welcome
        print('➡️ No referral code, navigating to welcome');
        Get.offAllNamed(Routes.welcome);
      }
    }

    // Mark initial launch as complete so future deep links are processed immediately
    deepLinkHandler.markInitialLaunchComplete();
  }

  /// Validates the stored access token by calling the refresh-token endpoint.
  /// Returns true if the token is valid or was successfully refreshed.
  Future<bool> _validateToken() async {
    try {
      final result = await NetworkClient.instance.callApi(
        ApiConstants.refreshToken,
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess && result.data?.statusCode == 200) {
        // Token refreshed successfully — save the new token
        final data = result.data!.data;
        if (isNotNullOrEmpty(data["data"]?['token'])) {
          await LocalStorageService.instance.saveString(
            StorageConstants.accessToken,
            data["data"]['token'],
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }
}
