import express from 'express';
const router = express.Router();

import authRoutes from './auth.routes.js';
import orgsRoutes from './orgs.routes.js';
import usersRoutes from './users.routes.js';
import studentsRoutes from './students.routes.js';
import attendanceRoutes from './attendance.routes.js';
import analyticsRoutes from './analytics.routes.js';
import backupRoutes from './backup.routes.js';
import notificationRoutes from './notifications.routes.js';
import feedbackRoutes from './feedback.routes.js';
import healthRoutes from './health.routes.js';
import sessionRoutes from './session.routes.js';

router.use('/auth', authRoutes);
router.use('/orgs', orgsRoutes);
router.use('/users', usersRoutes);
router.use('/students', studentsRoutes);
router.use('/attendance', attendanceRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/backup', backupRoutes);
router.use('/notifications', notificationRoutes);
router.use('/feedback', feedbackRoutes);
router.use('/health', healthRoutes);
router.use('/sessions', sessionRoutes);

export default router;
