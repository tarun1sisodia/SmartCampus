import express from 'express';
const router = express.Router();
import attendanceController from '../../controllers/attendance.controller.js';
import auth from '../../middleware/auth.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';
import validate from '../../middleware/validation.middleware.js';
import {  markAttendanceSchema  } from '../../validators/attendance.validator.js';

router.post('/sessions', auth, rbac('teacher', 'super_admin'), orgScope, attendanceController.createSession);
router.get('/sessions', auth, orgScope, attendanceController.listSessions);
router.post('/mark', auth, rbac('teacher', 'super_admin'), orgScope, validate(markAttendanceSchema), attendanceController.markBulk);
router.get('/session/:sessionId', auth, orgScope, attendanceController.getBySession);
router.get('/student/:studentId', auth, orgScope, attendanceController.studentSummary);

router.post('/sync', auth, rbac('teacher'), attendanceController.syncOffline);
router.get('/sessions/month', auth, attendanceController.listSessionsByMonth);

export default router;
