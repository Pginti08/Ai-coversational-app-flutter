import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';

class ReferFriendController extends GetxController {
  final RxString referralCode = "".obs;
  final RxBool isLoading = false.obs;

  // Referral link base URL - update this with your actual domain
  static const String referralBaseUrl = 'https://vousvous.com/share';

  @override
  void onInit() {
    super.onInit();
    loadReferralCode();
  }

  /// Load referral code from user data or generate dummy
  void loadReferralCode() {
    referralCode.value =
        "${LocalStorageService.instance.userInfo.value.data?.referralCode}";
  }

  /// Copy referral code to clipboard
  Future<void> copyReferralCode() async {
    try {
      await Clipboard.setData(ClipboardData(text: referralCode.value));
      HapticFeedback.mediumImpact();
      toast(
        'Referral code copied!',
        type: ToastType.success,
      );
    } catch (e) {
      toast('Failed to copy code');
    }
  }

  /// Build referral link URL
  String get referralLink {
    return '$referralBaseUrl?refferalCode=${referralCode.value}';
  }

  /// Share referral link via native share sheet
  Future<void> shareReferralLink() async {
    try {
      HapticFeedback.lightImpact();

      final message = '''
Join VousVous - Design your dream dress
with intelligent styling!

Use my referral code: ${referralCode.value}

Download the app and sign up with my code to get started!

$referralLink
'''
          .trim();

      await SharePlus.instance.share(
        ShareParams(
            text: message, title: 'Join VousVous with my referral code!'),
      );
    } catch (e) {
      toast('Failed to share');
    }
  }
}
