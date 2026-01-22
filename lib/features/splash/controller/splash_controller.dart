import 'package:get/get.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/deep_link_service.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for splash animation
    await Future.delayed(const Duration(milliseconds: 2800));

    // Check if user is logged in
    final isLoggedIn = isNotNullOrEmpty(
      LocalStorageService.instance.getString(StorageConstants.accessToken),
    );

    if (isLoggedIn) {
      // User is already logged in, go to home
      Get.offAllNamed(Routes.home);
      return;
    }

    // User not logged in - check for pending referral code from Play Store
    try {
      final deepLinkHandler = Get.find<DeepLinkHandler>();
      final pendingReferralCode =
          await deepLinkHandler.getPendingReferralCode();

      if (isNotNullOrEmpty(pendingReferralCode)) {
        print('🎯 Found pending referral code: $pendingReferralCode');
        print('➡️ Navigating to signup with prefilled referral code');

        // Navigate to signup with referral code
        Get.offAllNamed(Routes.signup, arguments: {
          "fromInvitePost": true,
          "referralCode": pendingReferralCode,
        });
        return;
      }
    } catch (e) {
      print('❌ Error checking pending referral code: $e');
    }

    // No referral code or error - go to welcome
    Get.offAllNamed(Routes.welcome);
  }
}
