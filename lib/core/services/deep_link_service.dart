import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/routes/app_pages.dart';

class DeepLinkHandler {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Initialize deep link listener
  Future<void> initDeepLinks() async {
    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Deep link error: $err');
    });

    // Handle initial link if app was opened via deep link
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('Received deep link: $uri');

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
      }
    } else {
      Get.offAllNamed(Routes.signup, arguments: {
        "fromInvitePost": true,
      });
    }
  }

  void navigateToShareScreen({String? imageUrl, String? productId}) {
    Get.toNamed(
      Routes.sharePreview,
      arguments: {
        if (imageUrl != null) "imageUrl": imageUrl,
        if (productId != null) "productId": productId,
      },
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
