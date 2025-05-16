import { Router } from 'express';
import authRoutes from './auth.routes';
import courseRoutes from './course.routes';
import subjectRoutes from './subject.routes';
import studentRoutes from './student.routes';
import attendanceRoutes from './attendance.routes';

const router = Router();

// Health check route
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'API is running',
    timestamp: new Date().toISOString()
  });
});

// Mount routes
router.use('/auth', authRoutes);
router.use('/courses', courseRoutes);
router.use('/subjects', subjectRoutes);
router.use('/students', studentRoutes);
router.use('/attendance', attendanceRoutes);

export default router;
