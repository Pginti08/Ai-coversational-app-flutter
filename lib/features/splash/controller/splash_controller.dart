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

    // User not logged in - check for pending referral code from Play Store

    final deepLinkHandler = Get.find<DeepLinkHandler>();
    final pendingReferralCode = await deepLinkHandler.getPendingReferralCode();

    if (isNotNullOrEmpty(pendingReferralCode)) {
      print('🎯 Found pending referral code: $pendingReferralCode');
      print('➡️ Navigating to signup with prefilled referral code');

      // Navigate to signup with referral code
      Get.offAllNamed(Routes.signup, arguments: {
        "referralCode": pendingReferralCode,
      });
    } else if (isNotNullOrEmpty(
        LocalStorageService.instance.getString(StorageConstants.accessToken))) {
      // User is already logged in, go to home
      Get.offAllNamed(Routes.home);
    } else {
      // No referral code or token - go to welcome
      Get.offAllNamed(Routes.welcome);
    }
  }
}
