// =============================================================
// notification.service.js  ->  ALGORITHM ONLY (source: backend/src/services/notification.service.js)
// Firebase Admin (FCM) push notifications.
// =============================================================

// init once: service account file from FCM_SERVICE_ACCOUNT_PATH, else applicationDefault()

// registerToken(userId, fcmToken, deviceId?) :
//   validate token length 16..4096; truncate deviceId to 128
//   $pull any older entry with the same token, then $addToSet { token, deviceId, createdAt }
//   $slice keep only the LAST 10 tokens per user (bounded array)

// sendPushNotification(userId, title, body, data) :
//   skip if firebase not initialised; multicast to ALL the user's stored fcm tokens
