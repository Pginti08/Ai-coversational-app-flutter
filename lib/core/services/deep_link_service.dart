import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/features/share-preview/controller/share_preview_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class DeepLinkHandler {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _pendingDeepLink;

  // Initialize deep link listener
  Future<void> initDeepLinks() async {
    // A. Hot Start Listener (Keep this for when app is running)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Deep link error: $err');
    });

    // B. Cold Start Handler (MODIFY THIS)
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _pendingDeepLink = uri;
        // 🚨 CRITICAL FIX: DO NOTHING ELSE HERE.
        // The SplashController will call processDelayedDeepLink() later.
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }
  // In DeepLinkHandler

  void _handleDeepLink(Uri uri) {
    print('Handling deep link: $uri (Executing immediately)');

    // 🚨 Remove _waitForAppReady and execute the navigation directly

    // Check if it's the share path
    if (uri.path == '/share') {
      if (isNotNullOrEmpty(LocalStorageService.instance
          .getString(StorageConstants.accessToken))) {
        final imageUrl = uri.queryParameters['imageUrl'];
        final productId = uri.queryParameters['productId'];

        if (productId != null || imageUrl != null) {
          // Navigate to your share screen
          navigateToShareScreen(imageUrl: imageUrl, productId: productId);
        }
      } else {
        // User not logged in, go to signup
        // This will successfully replace the home/welcome route pushed moments ago.
        Get.offAllNamed(Routes.signup, arguments: {
          "fromInvitePost": true,
          "deepLink": uri.toString(), // Store deep link to redirect after login
        });
      }
    } else {
      Get.offAllNamed(Routes.signup, arguments: {
        "fromInvitePost": true,
      });
    }
  }

  void navigateToShareScreen({String? imageUrl, String? productId}) {
    // Use WidgetsBinding to ensure navigation happens after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  // Call this method after your GetMaterialApp is built (optional but recommended)
  void processDelayedDeepLink() {
    if (_pendingDeepLink != null) {
      _handleDeepLink(_pendingDeepLink!);
      _pendingDeepLink = null;
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
    _pendingDeepLink = null;
  }
}
