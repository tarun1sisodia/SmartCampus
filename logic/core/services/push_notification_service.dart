// =============================================================
// push_notification_service.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/core/services/push_notification_service.dart)
// Firebase Cloud Messaging + local notifications.
// =============================================================

// _firebaseMessagingBackgroundHandler(message) (top-level) :
//   just log the background message id (no heavy work when app is killed)

// class PushNotificationService(apiClient?) :
//   ValueNotifier lastOpenedSessionId -> global signal "user tapped a session notification"

// init() :
//   skip on non-mobile
//   1. ask the user for notification permission (alert, badge, sound)
//   2. init local-notifications plugin with app icon + tap callback
//      create a HIGH-importance Android channel 'high_importance_channel'
//   3. register the background message handler
//   4. listen to FOREGROUND messages -> if they carry a notification, show it as a local notification
//   5. get the FCM device token -> POST it to backend /notifications/register-token
//   6. listen for token refresh -> re-register new token with backend
//   7. listen for notification taps (app in background / terminated)
//      -> set lastOpenedSessionId = data.sessionId (App widget navigates to the session)
//   wrap all in try-catch: failure here must never break the app

// _showForegroundNotification(message, channel) :
//   local notification with title/body from the FCM message; payload = sessionId

// _registerTokenWithBackend(token) : POST {token, platform:'mobile'}; failure only logged

// _handleMessageOpenedApp(message) / _onNotificationTapped(response) :
//   extract sessionId from data/payload -> if present set lastOpenedSessionId
