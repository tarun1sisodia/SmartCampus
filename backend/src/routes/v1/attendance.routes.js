const express = require('express');
const router = express.Router();
const attendanceController = require('../../controllers/attendance.controller');
const auth = require('../../middleware/auth.middleware');
const rbac = require('../../middleware/rbac.middleware');
const orgScope = require('../../middleware/orgScope.middleware');
const validate = require('../../middleware/validation.middleware');
const { markAttendanceSchema } = require('../../validators/attendance.validator');

router.post('/sessions', auth, rbac('teacher', 'super_admin'), orgScope, attendanceController.createSession);
router.get('/sessions', auth, orgScope, attendanceController.listSessions);
router.post('/mark', auth, rbac('teacher', 'super_admin'), orgScope, validate(markAttendanceSchema), attendanceController.markBulk);
router.get('/session/:sessionId', auth, orgScope, attendanceController.getBySession);
router.get('/student/:studentId', auth, orgScope, attendanceController.studentSummary);

router.post('/sync', auth, rbac('teacher'), attendanceController.syncOffline);
router.get('/sessions/month', auth, attendanceController.listSessionsByMonth);

module.exports = router;
