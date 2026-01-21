// lib/core/services/install_referrer_handler.dart

import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';

class InstallReferrerHandler {
  /// Get referral code from Play Store install referrer
  /// This captures referral data when user installs from Play Store
  static Future<String?> getReferralCode() async {
    try {
      print('📦 Checking Play Store install referrer...');

      // Get install referrer details from Play Store
      // Using android_play_install_referrer package which provides the actual referrer string
      final ReferrerDetails? details =
          await AndroidPlayInstallReferrer.installReferrer;

      if (details == null) {
        print('ℹ️ No install referrer details found');
        return null;
      }

      print('📦 Install Referrer Details:');
      print('   Referrer: ${details.installReferrer}');
      print('   Click time: ${details.referrerClickTimestampSeconds}');
      print('   Install time: ${details.installBeginTimestampSeconds}');
      print('   Google Play Instant: ${details.googlePlayInstantParam}');

      // Parse referral code from install referrer string
      // Format from Play Store: "refferalCode=XXXXX" or "utm_source=xxx&refferalCode=XXXXX"
      final referrer = details.installReferrer ?? '';

      if (referrer.isEmpty) {
        print('ℹ️ Install referrer string is empty');
        return null;
      }

      // Extract referral code from query parameters
      // Handles both "refferalCode" and "referralCode" spellings
      final params = Uri.splitQueryString(referrer);
      final referralCode = params['refferalCode'] ??
          params['referralCode'] ??
          params['referral_code'];

      if (referralCode != null && referralCode.isNotEmpty) {
        print('✅ Found referral code from Play Store install: $referralCode');
        return referralCode;
      }

      print('ℹ️ No referral code found in install referrer');
      print('   Raw referrer: $referrer');
      return null;
    } catch (e) {
      print('❌ Error getting install referrer: $e');
      return null;
    }
  }

  /// Check and store install referrer on app first launch
  /// Should be called from SplashController or main initialization
  static Future<void> checkAndStoreReferralCode() async {
    try {
      // Only check on first launch to avoid unnecessary API calls
      final hasCheckedReferrer = LocalStorageService.instance
              .getBool(StorageConstants.hasCheckedInstallReferrer) ??
          false;

      if (hasCheckedReferrer) {
        print('ℹ️ Install referrer already checked, skipping...');
        return;
      }

      // Get referral code from Play Store
      final referralCode = await getReferralCode();

      if (referralCode != null && referralCode.isNotEmpty) {
        print('💾 Storing referral code from install referrer: $referralCode');

        // Don't overwrite existing referral code (e.g., from deep link)
        final existingCode = LocalStorageService.instance
            .getString(StorageConstants.pendingReferralCode);

        if (existingCode == null || existingCode.isEmpty) {
          // Store for use in signup page
          await LocalStorageService.instance.saveString(
            StorageConstants.pendingReferralCode,
            referralCode,
          );

          print('✅ Referral code stored successfully');
        } else {
          print('ℹ️ Referral code already exists ($existingCode), keeping it');
        }
      }

      // Mark as checked so we don't check again
      await LocalStorageService.instance.saveBool(
        StorageConstants.hasCheckedInstallReferrer,
        true,
      );

      print('✅ Install referrer check completed');
    } catch (e) {
      print('❌ Error in checkAndStoreReferralCode: $e');
    }
  }
}
