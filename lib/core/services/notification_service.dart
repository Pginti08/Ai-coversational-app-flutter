import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/firebase_options.dart';
import 'package:vousvous/routes/app_pages.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('📩 BG Message ID: ${message.messageId}');
}

class FCMService {
  static final FCMService instance = FCMService._internal();
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialMessageHandledThisSession = false;

  String? _fcmToken;
  bool _handlersInitialized = false;

  // Navigation key
  GlobalKey<NavigatorState>? navigatorKey;

  /// Call this AFTER LOGIN
  Future<void> initializeAfterLogin() async {
    await _requestPermission();
    await _resolveToken();
    await _registerTokenIfNeeded();

    if (!_handlersInitialized) {
      _setupMessageHandlers();
      _handlersInitialized = true;
    }

    _messaging.onTokenRefresh.listen((token) async {
      debugPrint('🔄 FCM token refreshed');
      _fcmToken = token;
      await _registerTokenIfNeeded(force: true);
    });
  }

  /// Permission handling
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 Permission: ${settings.authorizationStatus}');
  }

  /// Token resolution
  Future<void> _resolveToken() async {
    try {
      if (Platform.isIOS) {
        await _waitForAPNSToken();
      }
      _fcmToken ??= await _messaging.getToken();
      debugPrint('🔑 FCM Token: $_fcmToken');
    } catch (e) {}
  }

  Future<void> _waitForAPNSToken() async {
    for (int i = 0; i < 5; i++) {
      final apns = await _messaging.getAPNSToken();
      if (apns != null) return;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Backend registration
  Future<void> _registerTokenIfNeeded({bool force = false}) async {
    if (_fcmToken == null) return;

    final storedToken =
        await LocalStorageService.instance.getString(StorageConstants.fcmToken);

    if (!force && storedToken == _fcmToken) {
      debugPrint('✅ FCM token already registered');
      return;
    }

    final deviceInfo = await _getDeviceInfo();

    final result = await NetworkClient.instance.callApi(
      ApiConstants.fcmToken,
      MethodType.post,
      baseUrlType: BaseUrl.base,
      params: deviceInfo,
    );

    if (result.isSuccess) {
      await LocalStorageService.instance
          .saveString(StorageConstants.fcmToken, _fcmToken!);
      debugPrint('✅ FCM token registered');
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final pkg = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      final d = await deviceInfo.androidInfo;
      return {
        'fcmToken': _fcmToken,
        'deviceType': 'android',
        'deviceId': d.id,
        'deviceName': '${d.manufacturer} ${d.model}',
        'version': pkg.version,
      };
    }

    final d = await deviceInfo.iosInfo;
    return {
      'fcmToken': _fcmToken,
      'deviceType': 'ios',
      'deviceId': d.identifierForVendor,
      'deviceName': '${d.name} ${d.model}',
      'version': pkg.version,
    };
  }

  /// Message handlers
  void _setupMessageHandlers() {
    // 1. FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground Message Received');
      if (message.notification != null) {
        _showForegroundNotification(message);
      }
    });

    // 2. BACKGROUND TAP
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📩 Background notification tapped');
      _handleNotificationTap(message, isBackgroundTap: true);
    });

    // 3. TERMINATED STATE CHECK
    _checkInitialMessage();
  }

  /// Check for notification that opened the app from terminated state
  /// Enhanced fix for Hot Restart/Reload issue
  Future<void> _checkInitialMessage() async {
    if (_initialMessageHandledThisSession) {
      debugPrint('⚠️ Initial message already handled in this session');
      return;
    }

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage == null) return;

    _initialMessageHandledThisSession = true; // ✅ BLOCK FUTURE CALLS

    debugPrint('📩 App opened from TERMINATED via notification');

    Future.delayed(const Duration(seconds: 3), () {
      _handleNotificationTap(initialMessage);
    });
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final accessToken =
        LocalStorageService.instance.getString(StorageConstants.accessToken);
    if (isNotNullOrEmpty(accessToken)) {
      toast(
        notification.body ?? "",
        title: notification.title,
        seconds: 3,
        type: ToastType.general,
        onTap: () {
          _handleNotificationTap(message, isForegroundTap: true);
        },
      );
    }
  }

  void _handleNotificationTap(
    RemoteMessage message, {
    bool isForegroundTap = false,
    bool isBackgroundTap = false,
    bool isTerminatedTap = false,
  }) {
    debugPrint(
        '📩 Notification TAPPED (Foreground: $isForegroundTap, Background: $isBackgroundTap, Terminated: $isTerminatedTap)');
    debugPrint('📩 Data: ${message.data}');

    final accessToken =
        LocalStorageService.instance.getString(StorageConstants.accessToken);
    if (!isNotNullOrEmpty(accessToken)) {
      debugPrint('⚠️ No access token, skipping navigation');
      return;
    }

    final cleanedData = _cleanNotificationData(message.data);
    _navigateBasedOnPayload(cleanedData);
  }

  void _navigateBasedOnPayload(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final imageUrl = data['imageUrl'] as String?;
      final productId = data['productId'] as String?;
      final orderItemId = data['orderItemId'] as String?;

      switch (type) {
        case 'QUOTATION_UPDATE':
          _navigateToQuotation(imageUrl, productId);
          break;

        case 'ORDER_UPDATE':
          _navigateToOrder(orderItemId);
          break;

        default:
          debugPrint('⚠️ Unknown notification type: $type');
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
    }
  }

  void _navigateToQuotation(String? imageUrl, String? productId) {
    Get.toNamed(
      Routes.quotationChat,
      arguments: {"imageUrl": imageUrl, "productId": productId},
    );
  }

  void _navigateToOrder(String? orderId) {
    Get.toNamed(
      Routes.orderDetail,
      arguments: {'orderId': orderId},
    );
  }

  String? get token => _fcmToken;
}

/// Helper to clean data
Map<String, dynamic> _cleanNotificationData(Map<String, dynamic> data) {
  final cleanedData = <String, dynamic>{};

  data.forEach((key, value) {
    if (value is String) {
      String cleanValue = value.trim();
      if (cleanValue.startsWith('"') && cleanValue.endsWith('"')) {
        cleanValue = cleanValue.substring(1, cleanValue.length - 1);
      }
      cleanValue = cleanValue.replaceAll('\\"', '');
      cleanedData[key] = cleanValue;
    } else {
      cleanedData[key] = value;
    }
  });

  return cleanedData;
}
