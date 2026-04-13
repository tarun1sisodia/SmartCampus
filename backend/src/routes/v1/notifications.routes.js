import express from 'express';
const router = express.Router();
import notificationController from '../../controllers/notification.controller.js';
import auth from '../../middleware/auth.middleware.js';

router.post('/register-token', auth, notificationController.registerToken);

export default router;
