import notificationService from '../services/notification.service.js';
import {  sendSuccess  } from '../utils/apiResponse.js';

export const registerToken = async (req, res, next) => {
  try {
    const { fcmToken, deviceId } = req.body;
    await notificationService.registerToken(req.user.id, fcmToken, deviceId);
    sendSuccess(res, { success: true });
  } catch (err) {
    next(err);
  }
};

export default { registerToken };
