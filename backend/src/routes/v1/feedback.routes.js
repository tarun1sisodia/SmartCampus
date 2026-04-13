import express from 'express';
const router = express.Router();
import feedbackController from '../../controllers/feedback.controller.js';
import auth from '../../middleware/auth.middleware.js';
import validate from '../../middleware/validation.middleware.js';
import {  feedbackSchema  } from '../../validators/feedback.validator.js';

router.post('/', auth, validate(feedbackSchema), feedbackController.submit);

export default router;
