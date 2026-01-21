import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/install_referrer_service.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/features/share-preview/controller/share_preview_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class DeepLinkHandler {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _pendingDeepLink;

  /// Initialize deep link listener
  /// Handles HTTPS App Links, custom URL schemes, and install referrer
  Future<void> initDeepLinks() async {
    print('🔗 Initializing Deep Link Handler...');

    // A. Hot Start Listener (App is already running)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('🔥 Hot start deep link received: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      print('❌ Deep link error: $err');
    });

    // B. Cold Start Handler (App launched via link)
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        print('❄️ Cold start deep link received: $uri');
        _pendingDeepLink = uri;
        // Will be processed later by processDelayedDeepLink()
      } else {
        print('ℹ️ No initial deep link found');
      }
    } catch (e) {
      print('❌ Failed to get initial link: $e');
    }

    // C. Platform-specific initialization
    if (Platform.isIOS) {
      // iOS: Check clipboard for referral code
      await _checkClipboardForReferralCode();
    } else if (Platform.isAndroid) {
      // Android: Check Play Store install referrer
      await InstallReferrerHandler.checkAndStoreReferralCode();
    }

    print('✅ Deep Link Handler initialized');
  }

  /// iOS: Check clipboard for referral code
  /// This handles the case where user comes from web and code is copied
  Future<void> _checkClipboardForReferralCode() async {
    try {
      print('📋 Checking iOS clipboard for referral code...');

      // Check if clipboard has strings (this still triggers popup in iOS 14+)
      final hasStrings = await Clipboard.hasStrings();
      if (!hasStrings) {
        print('ℹ️ Clipboard is empty');
        return;
      }

      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        final text = clipboardData.text!;
        print('📋 Clipboard content found: ${text.length} chars');

        // Check if clipboard contains a referral code pattern
        // Pattern: "refferalCode-XXXXX" or "refferalCode:XXXXX" or just the code
        final referralCodePattern = RegExp(
          r'refferalCode[-:]?\s*([A-Z0-9]+)',
          caseSensitive: false,
        );
        final match = referralCodePattern.firstMatch(text);

        if (match != null) {
          final referralCode = match.group(1);
          print('✅ Found referral code in clipboard: $referralCode');

          // Don't overwrite if there's already a referral code from deep link
          final existingCode = LocalStorageService.instance
              .getString(StorageConstants.pendingReferralCode);

          if (existingCode == null || existingCode.isEmpty) {
            // Store referral code for use in signup
            await LocalStorageService.instance.saveString(
              StorageConstants.pendingReferralCode,
              referralCode ?? '',
            );
            print('💾 Referral code stored from clipboard');
          } else {
            print('ℹ️ Referral code already exists, skipping clipboard code');
          }

          // Clear clipboard for security
          await Clipboard.setData(const ClipboardData(text: ''));
          print('🗑️ Clipboard cleared for security');
        } else {
          print('ℹ️ No referral code pattern found in clipboard');
        }
      } else {
        print('ℹ️ Clipboard is empty');
      }
    } catch (e) {
      print('❌ Error checking clipboard: $e');
    }
  }

  /// Main deep link handler
  /// Processes both HTTPS and custom scheme links
  void _handleDeepLink(Uri uri) {
    print('🔗 Processing deep link: $uri');
    print('   Scheme: ${uri.scheme}');
    print('   Host: ${uri.host}');
    print('   Path: ${uri.path}');
    print('   Query params: ${uri.queryParameters}');

    // Handle both HTTPS and custom scheme URLs
    // HTTPS: https://vousvous.com/share?params
    // Custom: vousvous://share?params

    final isSharePath = uri.path == '/share' || uri.host == 'share';

    if (isSharePath) {
      final imageUrl = uri.queryParameters['imageUrl'];
      final productId = uri.queryParameters['productId'];
      final referralCode = uri.queryParameters['refferalCode'] ??
          uri.queryParameters['referralCode']; // Support both spellings

      print('📦 Share link detected:');
      print('   Product ID: $productId');
      print(
          '   Image URL: ${imageUrl != null ? "${imageUrl.substring(0, 50)}..." : "null"}');
      print('   Referral Code: $referralCode');

      // Store referral code if present (will be used in signup)
      if (referralCode != null && referralCode.isNotEmpty) {
        _handleReferralCode(referralCode);
      }

      // Check if user is logged in
      final isLoggedIn = isNotNullOrEmpty(
        LocalStorageService.instance.getString(StorageConstants.accessToken),
      );
      print('🔐 User logged in: $isLoggedIn');

      if (isLoggedIn) {
        // User is logged in
        if (productId != null || imageUrl != null) {
          print('➡️ Navigating to share screen');
          navigateToShareScreen(imageUrl: imageUrl, productId: productId);
        } else if (referralCode != null) {
          print(
              '➡️ User already logged in, ignoring referral code, going to home');
          Get.offAllNamed(Routes.home);
        } else {
          print('➡️ No specific content, going to home');
          Get.offAllNamed(Routes.home);
        }
      } else {
        // User not logged in - go to signup with referral code prefilled
        print('➡️ Navigating to signup with referral code');
        Get.offAllNamed(Routes.signup, arguments: {
          "fromInvitePost": true,
          "deepLink": uri.toString(),
          if (referralCode != null) "referralCode": referralCode,
        });
      }
    } else {
      print('➡️ Unknown path, going to signup');
      Get.offAllNamed(Routes.signup, arguments: {
        "fromInvitePost": true,
      });
    }
  }

  /// Store referral code from deep link parameters or install referrer
  Future<void> _handleReferralCode(String referralCode) async {
    print('💾 Storing referral code: $referralCode');

    // Don't overwrite existing referral code
    final existingCode = LocalStorageService.instance
        .getString(StorageConstants.pendingReferralCode);

    if (existingCode == null || existingCode.isEmpty) {
      await LocalStorageService.instance.saveString(
        StorageConstants.pendingReferralCode,
        referralCode,
      );
      print('✅ Referral code stored successfully');
    } else {
      print('ℹ️ Referral code already exists ($existingCode), keeping it');
    }
  }

  /// Navigate to share preview screen
  void navigateToShareScreen({String? imageUrl, String? productId}) {
    // Use WidgetsBinding to ensure navigation happens after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎯 Opening share preview screen');

      // Clean up existing controller if present
      if (Get.isRegistered<SharePreviewController>()) {
        Get.delete<SharePreviewController>();
      }

      Get.toNamed(
        Routes.sharePreview,
        arguments: {
          if (imageUrl != null) "imageUrl": imageUrl,
          if (productId != null) "productId": productId,
        },
      );
    });
  }

  /// Call this method after your GetMaterialApp is built
  /// Typically called from SplashController after initialization
  void processDelayedDeepLink() {
    if (_pendingDeepLink != null) {
      print('⏰ Processing delayed deep link: $_pendingDeepLink');
      _handleDeepLink(_pendingDeepLink!);
      _pendingDeepLink = null;
    } else {
      print('ℹ️ No pending deep link to process');
    }
  }

  /// Get stored referral code (call this in your signup page)
  Future<String?> getPendingReferralCode() async {
    final code = LocalStorageService.instance.getString(
      StorageConstants.pendingReferralCode,
    );

    print('📱 Retrieved pending referral code: $code');
    return code;
  }

  /// Clean up resources
  void dispose() {
    print('🧹 Disposing Deep Link Handler');
    _linkSubscription?.cancel();
    _pendingDeepLink = null;
  }
}
