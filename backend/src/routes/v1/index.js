const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const orgsRoutes = require('./orgs.routes');
const usersRoutes = require('./users.routes');
const studentsRoutes = require('./students.routes');
const attendanceRoutes = require('./attendance.routes');
const analyticsRoutes = require('./analytics.routes');
const backupRoutes = require('./backup.routes');

router.use('/auth', authRoutes);
router.use('/orgs', orgsRoutes);
router.use('/users', usersRoutes);
router.use('/students', studentsRoutes);
router.use('/attendance', attendanceRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/backup', backupRoutes);

module.exports = router;
