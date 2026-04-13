const express = require('express');
const router = express.Router();
const authController = require('../../controllers/auth.controller');
const authMiddleware = require('../../middleware/auth.middleware');
const rateLimiters = require('../../middleware/rateLimiter');
const validate = require('../../middleware/validation.middleware');
const { loginSchema, forgotSchema, resetSchema } = require('../../validators/auth.validator');

router.post('/login', rateLimiters.strictLimiter, validate(loginSchema), authController.login);
router.post('/register', authController.registerSuperAdmin);
router.post('/refresh', authController.refresh);
router.post('/logout', authMiddleware, authController.logout);
router.post('/forgot-password', validate(forgotSchema), authController.forgotPassword);
router.post('/reset-password', validate(resetSchema), authController.resetPassword);

module.exports = router;
