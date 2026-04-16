import express from 'express';
const router = express.Router();
import attendanceController from '../../controllers/attendance.controller.js';
import auth from '../../middleware/auth.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';

// This file specifically maps to /api/v1/sessions to satisfy the teacher app dashboard
router.get('/', auth, orgScope, attendanceController.listSessions);

export default router;
