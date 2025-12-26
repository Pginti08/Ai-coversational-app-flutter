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
import 'package:vousvous/firebase_options.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('📩 BG Message ID: ${message.messageId}');
  debugPrint('📩 BG Data: ${message.data}');

  // Store notification for later handling when app opens
  await _storeNotificationForLater(message);
}

/// Helper to store notification data
Future<void> _storeNotificationForLater(RemoteMessage message) async {
  try {
    await LocalStorageService.instance.saveString(
      'pending_notification',
      message.data.toString(),
    );
  } catch (e) {
    debugPrint('Error storing notification: $e');
  }
}

class FCMService {
  static final FCMService instance = FCMService._internal();
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  bool _handlersInitialized = false;

  // Navigation key - set this from your main.dart
  GlobalKey<NavigatorState>? navigatorKey;

  /// Call this AFTER LOGIN (safe to call multiple times)
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

  /// Robust token resolution
  Future<void> _resolveToken() async {
    if (Platform.isIOS) {
      await _waitForAPNSToken();
    }

    _fcmToken ??= await _messaging.getToken();
    debugPrint('🔑 FCM Token: $_fcmToken');
  }

  /// iOS APNs readiness wait
  Future<void> _waitForAPNSToken() async {
    for (int i = 0; i < 5; i++) {
      final apns = await _messaging.getAPNSToken();
      if (apns != null) {
        debugPrint('📱 APNs ready');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    debugPrint('⚠️ APNs token not ready after retries');
  }

  /// Prevent duplicate backend registration
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

  /// Device info (unchanged logic, cleaner)
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

  /// Message handlers (registered ONCE)
  void _setupMessageHandlers() {
    // FOREGROUND - App is open and visible
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // BACKGROUND - App is in background, user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // TERMINATED - App was completely closed, user taps notification
    _checkInitialMessage();
  }

  /// Check for notification that opened the app from terminated state
  Future<void> _checkInitialMessage() async {
    final msg = await _messaging.getInitialMessage();
    if (msg != null) {
      debugPrint('📩 App opened from TERMINATED state');
      // Delay navigation until app is fully initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(msg);
      });
    }
  }

  /// Handle foreground messages (just log, no UI shown)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📩 FOREGROUND Message');
    debugPrint('📩 Title: ${message.notification?.title}');
    debugPrint('📩 Body: ${message.notification?.body}');
    debugPrint('📩 Data: ${message.data}');

    // Optional: Navigate immediately on foreground message
    // Uncomment if you want auto-navigation without user tap
    // _navigateBasedOnPayload(message.data);
  }

  /// Handle notification tap (background or terminated)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('📩 Notification TAPPED');
    debugPrint('📩 Data: ${message.data}');

    // Navigate based on notification data
    _navigateBasedOnPayload(message.data);
  }

  /// Navigate based on notification payload
  void _navigateBasedOnPayload(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final id = data['id'] as String?;

      debugPrint('🧭 Navigating to: $type with ID: $id');

      switch (type) {
        case 'chat':
        case 'message':
          _navigateToChat(id);
          break;

        case 'order':
          _navigateToOrder(id);
          break;

        case 'profile':
          _navigateToProfile(id);
          break;

        case 'booking':
          _navigateToBooking(id);
          break;

        default:
          _navigateToHome();
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      _navigateToHome();
    }
  }

  // Navigation methods - customize these based on your GetX routes
  void _navigateToChat(String? chatId) {
    Get.toNamed(
      '/chat',
      arguments: {'chatId': chatId},
    );
  }

  void _navigateToOrder(String? orderId) {
    Get.toNamed(
      '/order-details',
      arguments: {'orderId': orderId},
    );
  }

  void _navigateToProfile(String? userId) {
    Get.toNamed(
      '/profile',
      arguments: {'userId': userId},
    );
  }

  void _navigateToBooking(String? bookingId) {
    Get.toNamed(
      '/booking-details',
      arguments: {'bookingId': bookingId},
    );
  }

  void _navigateToHome() {
    Get.offAllNamed('/home');
  }

  String? get token => _fcmToken;
}
