import { z } from 'zod';
import notificationService from '../services/notification.service.js';
import { sendSuccess } from '../utils/apiResponse.js';

const registerTokenSchema = z.object({
  fcmToken: z.string().min(16).max(4096),
  deviceId: z.string().max(128).optional(),
});

export const registerToken = async (req, res, next) => {
  try {
    const parsed = registerTokenSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ success: false, message: 'Invalid fcmToken or deviceId' });
    }
    const { fcmToken, deviceId } = parsed.data;
    await notificationService.registerToken(req.user.id, fcmToken, deviceId);
    sendSuccess(res, { success: true });
  } catch (err) {
    next(err);
  }
};

export default { registerToken };
