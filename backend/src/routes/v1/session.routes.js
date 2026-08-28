import express from 'express';
const router = express.Router();
import attendanceController from '../../controllers/attendance.controller.js';
import auth from '../../middleware/auth.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';

// This file maps to /api/v1/sessions for the teacher app dashboard.
router.get('/', auth, orgScope, attendanceController.listSessions); // supports ?date=today and ?month=YYYY-MM
router.get('/:sessionId', auth, orgScope, attendanceController.getSession); // session detail + attendance

export default router;
