import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/firebase_options.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');
}

class FCMService {
  // Singleton instance
  static final FCMService instance = FCMService._internal();

  // Private constructor
  FCMService._internal();

  late final FirebaseMessaging _firebaseMessaging;
  String? _fcmToken;
  bool _isInitialized = false;

  /// Initialize Firebase and FCM
  Future<void> initialize() async {
    try {
      if (_isInitialized) {
        debugPrint('✅ FCMService already initialized');
        return;
      }

      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');

      // Initialize FirebaseMessaging instance
      _firebaseMessaging = FirebaseMessaging.instance;
      _isInitialized = true;

      // Request notification permissions
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  /// Initialize Firebase and FCM (called after login/signup)
  Future<void> initializeAndRegisterAfterLogin() async {
    try {
      // Check if already registered
      final isRegistered = LocalStorageService.instance
              .getString(StorageConstants.fcmTokenRegistered) ==
          'true';

      if (isRegistered) {
        debugPrint('✅ FCM token already registered, skipping...');
        return;
      }

      // Initialize Firebase if not already done
      if (!_isInitialized) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase initialized successfully');

        // Initialize FirebaseMessaging instance
        _firebaseMessaging = FirebaseMessaging.instance;
        _isInitialized = true;
      }

      // Request notification permissions
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Register token with backend (only after login)
      await registerTokenWithBackend();

      // Setup message handlers
      _setupMessageHandlers();

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        registerTokenWithBackend();
      });
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          '📱 Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional notification permission');
      } else {
        debugPrint(
            '❌ User declined or has not accepted notification permission');
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      // For iOS, you might need to call getAPNSToken first
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          debugPrint('📱 APNS Token: $apnsToken');
        } else {
          debugPrint('⚠️ APNS token not available yet');
        }
      }

      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('🔑 FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String deviceType = '';
    String deviceId = '';
    String deviceName = '';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceType = 'android';
        deviceId = androidInfo.id; // Android ID
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';

        debugPrint('📱 Android Device Info:');
        debugPrint('   - Device: $deviceName');
        debugPrint('   - ID: $deviceId');
        debugPrint('   - Android Version: ${androidInfo.version.release}');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceType = 'ios';
        deviceId = iosInfo.identifierForVendor ?? ''; // iOS Vendor ID
        deviceName = '${iosInfo.name} ${iosInfo.model}';

        debugPrint('📱 iOS Device Info:');
        debugPrint('   - Device: $deviceName');
        debugPrint('   - ID: $deviceId');
        debugPrint('   - iOS Version: ${iosInfo.systemVersion}');
      }
    } catch (e) {
      debugPrint('❌ Error getting device info: $e');
    }

    return {
      'fcmToken': _fcmToken ?? '',
      'deviceType': deviceType,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }

  /// Register FCM token with backend
  Future<void> registerTokenWithBackend() async {
    try {
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        debugPrint('⚠️ FCM token not available, skipping registration');
        return;
      }

      final deviceInfo = await _getDeviceInfo();

      debugPrint('📤 Registering FCM token with backend...');
      debugPrint('   - FCM Token: ${deviceInfo['fcmToken']}');
      debugPrint('   - Device Type: ${deviceInfo['deviceType']}');
      debugPrint('   - Device ID: ${deviceInfo['deviceId']}');
      debugPrint('   - Device Name: ${deviceInfo['deviceName']}');
      debugPrint('   - Version: ${deviceInfo['version']}');

      final result = await NetworkClient.instance.callApi(
        ApiConstants.fcmToken,
        MethodType.post,
        baseUrlType: BaseUrl.base,
        params: {
          'fcmToken': deviceInfo['fcmToken'],
          'deviceType': deviceInfo['deviceType'],
          'deviceId': deviceInfo['deviceId'],
          'deviceName': deviceInfo['deviceName'],
          'version': deviceInfo['version'],
        },
      );

      if (result.isSuccess) {
        debugPrint('✅ FCM token registered successfully with backend');
        debugPrint('   Response: ${result.data?.data}');

        // Mark as registered in local storage to prevent duplicate registrations
        await LocalStorageService.instance.saveString(
          StorageConstants.fcmTokenRegistered,
          'true',
        );
        debugPrint('✅ FCM registration status saved');
      } else {
        debugPrint('❌ Failed to register FCM token: ${result.error}');
      }
    } catch (e) {
      debugPrint('❌ Error registering FCM token with backend: $e');
    }
  }

  /// Setup message handlers for foreground, background, and terminated states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground message received:');
      debugPrint('   - Title: ${message.notification?.title}');
      debugPrint('   - Body: ${message.notification?.body}');
      debugPrint('   - Data: ${message.data}');

      // You can show a local notification here or update UI
      _handleMessage(message);
    });

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Background message opened:');
      debugPrint('   - Title: ${message.notification?.title}');
      debugPrint('   - Body: ${message.notification?.body}');
      debugPrint('   - Data: ${message.data}');

      _handleMessage(message);
    });

    // Handle messages when app is terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Check if app was opened from a terminated state via notification
    _checkInitialMessage();
  }

  /// Check if app was opened from a notification while terminated
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('📬 App opened from terminated state via notification:');
      debugPrint('   - Title: ${initialMessage.notification?.title}');
      debugPrint('   - Body: ${initialMessage.notification?.body}');
      debugPrint('   - Data: ${initialMessage.data}');

      _handleMessage(initialMessage);
    }
  }

  /// Handle incoming messages and navigate accordingly
  void _handleMessage(RemoteMessage message) {
    // Handle navigation or actions based on message data
    // Example: Navigate to specific screen based on message type
    if (message.data.containsKey('type')) {
      String type = message.data['type'];
      debugPrint('📌 Message type: $type');

      // Add your navigation logic here based on message type
      // For example:
      // if (type == 'order') {
      //   Get.toNamed(Routes.orders);
      // } else if (type == 'chat') {
      //   Get.toNamed(Routes.chat);
      // }
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }
}
