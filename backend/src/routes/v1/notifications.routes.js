const express = require('express');
const router = express.Router();
const notificationController = require('../../controllers/notification.controller');
const auth = require('../../middleware/auth.middleware');

router.post('/register-token', auth, notificationController.registerToken);

module.exports = router;
