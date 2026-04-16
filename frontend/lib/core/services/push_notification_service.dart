import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

import '../utils/platform_helper.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService({ApiClient? apiClient})
      : _apiClient = apiClient,
        _logger = Logger();

  final ApiClient? _apiClient;
  final Logger _logger;
  final ValueNotifier<String?> lastOpenedSessionId = ValueNotifier<String?>(null);
  
  // These will only be used if PlatformHelper.isMobile is true
  FirebaseMessaging? _firebaseMessaging;
  FlutterLocalNotificationsPlugin? _localNotificationsPlugin;

  Future<void> init() async {
    if (!PlatformHelper.isMobile) {
      _logger.i('📵 Push notifications skipped on non-mobile platform');
      return;
    }
    
    _firebaseMessaging = FirebaseMessaging.instance;
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    try {
      // 1. Request Permission
      NotificationSettings settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.i('User granted permission: ${settings.authorizationStatus}');

      // 2. Initialize Local Notifications (for foreground popups)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _localNotificationsPlugin!.initialize(
        onDidReceiveNotificationResponse: _onNotificationTapped,
        settings: initializationSettings,
      );

      // Create a High Importance Android Channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.', // description
        importance: Importance.max,
      );

      await _localNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Register Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Listen for Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Got a message whilst in the foreground!');
        _logger.i('Message data: ${message.data}');

        if (message.notification != null) {
          _logger.i('Message also contained a notification: ${message.notification}');
          _showForegroundNotification(message, channel);
        }
      });

      // 5. Retrieve FCM Token
      String? token = await _firebaseMessaging!.getToken();
      if (token != null) {
        _logger.i('FCM Device Token: $token');
        await _registerTokenWithBackend(token);
      }

      // 6. Handle token refresh
      _firebaseMessaging!.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token Refreshed: $newToken');
        _registerTokenWithBackend(newToken);
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      final initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

    } catch (e) {
      _logger.e('Failed to initialize PushNotificationService: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message, AndroidNotificationChannel channel) {
    if (_localNotificationsPlugin == null) return;
    
    final notification = message.notification;
    if (notification == null) return;
    final sessionId = message.data['sessionId']?.toString();
    _localNotificationsPlugin!.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF3B82F6),
        ),
      ),
      payload: sessionId,
    );
  }

  Future<void> _registerTokenWithBackend(String token) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return;
    }
    try {
      await apiClient.dio.post(
        Endpoints.registerNotificationToken,
        data: {'token': token, 'platform': 'mobile'},
      );
    } catch (e) {
      _logger.w('Failed to register FCM token: $e');
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final sessionId = message.data['sessionId']?.toString();
    if (sessionId != null && sessionId.isNotEmpty) {
      lastOpenedSessionId.value = sessionId;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Notification tapped with payload: ${response.payload}');
    final sessionId = response.payload;
    if (sessionId != null && sessionId.isNotEmpty) {
      lastOpenedSessionId.value = sessionId;
    }
  }
}
