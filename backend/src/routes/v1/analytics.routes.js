import express from 'express';
const router = express.Router();
import analyticsController from '../../controllers/analytics.controller.js';
import auth from '../../middleware/auth.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';

router.get('/class/:courseId', auth, orgScope, analyticsController.classReport);
router.get('/student/:studentId', auth, orgScope, analyticsController.studentTrend);
router.get('/teacher/:teacherId', auth, rbac('super_admin', 'org_admin'), orgScope, analyticsController.teacherPerformance);

export default router;
