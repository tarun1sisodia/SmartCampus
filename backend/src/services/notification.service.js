import admin from 'firebase-admin';
import User from '../models/User.model.js';
import path from 'path';
import fs from 'fs';

// Make sure to load credentials properly, typically from a file linked by FCM_SERVICE_ACCOUNT_PATH
let isInitialized = false;

if (process.env.FCM_SERVICE_ACCOUNT_PATH) {
  try {
    const certPath = path.resolve(process.cwd(), process.env.FCM_SERVICE_ACCOUNT_PATH.endsWith('.json') ? process.env.FCM_SERVICE_ACCOUNT_PATH : `${process.env.FCM_SERVICE_ACCOUNT_PATH}.json`);
    const serviceAccount = JSON.parse(fs.readFileSync(certPath, 'utf8'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    isInitialized = true;
  } catch (error) {
    console.error('Failed to initialize Firebase Admin SDK:', error);
  }
} else if (process.env.NODE_ENV !== 'test') {    
  // If running on a cloud provider with applicationDefault()
  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    isInitialized = true;
  } catch (error) {
    console.error('Failed to initialize applicationDefault Firebase Admin:', error);
  }
}

export const registerToken = async (userId, fcmToken, deviceId) => {
  if (typeof fcmToken !== 'string' || fcmToken.length < 16 || fcmToken.length > 4096) {
    throw Object.assign(new Error('Invalid fcmToken'), { status: 400 });
  }
  const safeDeviceId = typeof deviceId === 'string' ? deviceId.slice(0, 128) : undefined;

  // Remove any previous entry for the same token (createdAt differs, so
  // $addToSet alone used to grow the array without bound).
  await User.findByIdAndUpdate(userId, { $pull: { fcmTokens: { token: fcmToken } } });
  await User.findByIdAndUpdate(userId, {
    $addToSet: {
      fcmTokens: { token: fcmToken, deviceId: safeDeviceId, createdAt: new Date() }
    }
  });
  // Cap stored tokens per user to bound the array.
  await User.findByIdAndUpdate(userId, [
    { $set: { fcmTokens: { $slice: ['$fcmTokens', -10] } } },
  ]);
};

export const sendPushNotification = async (userId, title, body, data = {}) => {
  if (!isInitialized) return;
  const user = await User.findById(userId);
  if (!user || !user.fcmTokens || !user.fcmTokens.length) return;
  
  const tokens = user.fcmTokens.map(t => t.token);
  
  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data
  });
};

export default { registerToken, sendPushNotification };
