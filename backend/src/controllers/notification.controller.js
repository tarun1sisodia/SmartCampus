const notificationService = require('../services/notification.service');
const { sendSuccess } = require('../utils/apiResponse');

exports.registerToken = async (req, res, next) => {
  try {
    const { fcmToken, deviceId } = req.body;
    await notificationService.registerToken(req.user.id, fcmToken, deviceId);
    sendSuccess(res, { success: true });
  } catch (err) {
    next(err);
  }
};
