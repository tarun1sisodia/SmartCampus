import express from 'express';
const router = express.Router();
import attendanceQrController from '../../controllers/attendanceQr.controller.js';
import attendanceController from '../../controllers/attendance.controller.js';
import auth from '../../middleware/auth.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';
import validate from '../../middleware/validation.middleware.js';
import rateLimiters from '../../middleware/rateLimiter.js';
import { markAttendanceSchema } from '../../validators/attendance.validator.js';

router.post('/sessions', auth, rbac('teacher', 'super_admin'), orgScope, attendanceController.createSession);
router.get('/sessions', auth, orgScope, attendanceController.listSessions);
router.get('/sessions/month', auth, orgScope, attendanceController.listSessionsByMonth);
router.post('/mark', auth, rbac('teacher', 'super_admin'), orgScope, rateLimiters.standardLimiter, validate(markAttendanceSchema), attendanceController.markBulk);
router.get('/session/:sessionId', auth, orgScope, attendanceController.getBySession);
router.get('/student/:studentId', auth, orgScope, attendanceController.studentSummary);

router.post('/sync', auth, rbac('teacher'), orgScope, rateLimiters.standardLimiter, attendanceController.syncOffline);

// QR Attendance endpoints.
// generate: the session's teacher displays the rotating QR.
router.get('/qr/generate/:sessionId', auth, rbac('teacher', 'super_admin'), orgScope, rateLimiters.standardLimiter, attendanceQrController.generateDynamicQr);
// verify: the attendee (student role — introduced with the student app)
// scans and marks themselves present. Session-window, tenant and optional
// geofence checks are enforced in the controller.
router.post('/qr/verify', auth, rbac('student'), orgScope, rateLimiters.strictLimiter, attendanceQrController.verifyQrAttendance);

export default router;
