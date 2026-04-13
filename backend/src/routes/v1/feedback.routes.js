const express = require('express');
const router = express.Router();
const feedbackController = require('../../controllers/feedback.controller');
const auth = require('../../middleware/auth.middleware');
const validate = require('../../middleware/validation.middleware');
const { feedbackSchema } = require('../../validators/feedback.validator');

router.post('/', auth, validate(feedbackSchema), feedbackController.submit);

module.exports = router;
