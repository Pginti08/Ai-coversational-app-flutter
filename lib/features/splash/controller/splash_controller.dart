import 'package:get/get.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/deep_link_service.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
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

    // Check if user is logged in
    final isLoggedIn = isNotNullOrEmpty(
      LocalStorageService.instance.getString(StorageConstants.accessToken),
    );
    print('🔐 User logged in status: $isLoggedIn');

    // Get pending referral code (from Play Store install referrer or deep link)
    final pendingReferralCode = await deepLinkHandler.getPendingReferralCode();
    print('📋 Pending referral code: $pendingReferralCode');

    if (isLoggedIn) {
      // USER IS LOGGED IN
      print('👤 User is logged in');

      // First navigate to home, then process any pending deep links
      Get.offAllNamed(Routes.home);

      // Process delayed deep link AFTER navigation to home
      // This handles the case where logged-in user opens app via share link
      await Future.delayed(const Duration(milliseconds: 300));
      deepLinkHandler.processDelayedDeepLink();

      print('✅ Navigated to home and processed pending deep links');
    } else {
      // USER IS NOT LOGGED IN
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
    }

    // Mark initial launch as complete so future deep links are processed immediately
    deepLinkHandler.markInitialLaunchComplete();
  }
}
