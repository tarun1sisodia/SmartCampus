import express from 'express';
const router = express.Router();
import authController from '../../controllers/auth.controller.js';
import authMiddleware from '../../middleware/auth.middleware.js';
import rateLimiters from '../../middleware/rateLimiter.js';
import validate from '../../middleware/validation.middleware.js';
import {  loginSchema, forgotSchema, resetSchema  } from '../../validators/auth.validator.js';

router.post('/login', rateLimiters.strictLimiter, validate(loginSchema), authController.login);
router.post('/register', authController.registerSuperAdmin);
router.post('/refresh', authController.refresh);
router.post('/logout', authMiddleware, authController.logout);
router.post('/forgot-password', validate(forgotSchema), authController.forgotPassword);
router.post('/reset-password', validate(resetSchema), authController.resetPassword);

export default router;
