import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService({ApiClient? apiClient})
      : _apiClient = apiClient,
        _logger = Logger();

  final ApiClient? _apiClient;
  final Logger _logger;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ValueNotifier<String?> lastOpenedSessionId = ValueNotifier<String?>(null);

  Future<void> init() async {
    try {
      // 1. Request Permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
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

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create a High Importance Android Channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.', // description
        importance: Importance.max,
      );

      await _localNotificationsPlugin
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
          _showForegroundNotification(message.notification!, channel);
        }
      });

      // 5. Retrieve FCM Token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        _logger.i('FCM Device Token: $token');
        await _registerTokenWithBackend(token);
      }

      // 6. Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token Refreshed: $newToken');
        _registerTokenWithBackend(newToken);
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

    } catch (e) {
      _logger.e('Failed to initialize PushNotificationService: $e');
    }
  }

  void _showForegroundNotification(RemoteNotification notification, AndroidNotificationChannel channel) {
    _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF3B82F6),
        ),
      ),
      payload: notification.body,
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
  }
}
