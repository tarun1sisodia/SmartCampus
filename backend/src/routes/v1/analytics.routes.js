const express = require('express');
const router = express.Router();
const analyticsController = require('../../controllers/analytics.controller');
const auth = require('../../middleware/auth.middleware');
const orgScope = require('../../middleware/orgScope.middleware');
const rbac = require('../../middleware/rbac.middleware');

router.get('/class/:courseId', auth, orgScope, analyticsController.classReport);
router.get('/student/:studentId', auth, orgScope, analyticsController.studentTrend);
router.get('/teacher/:teacherId', auth, rbac('super_admin', 'org_admin'), orgScope, analyticsController.teacherPerformance);

module.exports = router;
