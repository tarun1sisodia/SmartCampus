import { Router } from 'express';
import CourseController from '../controllers/course.controller';
import { authenticateToken, requireRole } from '../middleware/auth';
import { UserRole } from '../types';
import validate from '../middleware/validate';
import courseSchema from '../validations/course.validation';

const router = Router();

// Apply authentication to all course routes
router.use(authenticateToken);

// GET all courses - accessible by admin and teachers
router.get(
  '/',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  CourseController.getAllCourses
);

// GET single course by ID - accessible by admin and teachers
router.get(
  '/:id',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  CourseController.getCourse
);

// POST create new course - admin only
router.post(
  '/',
  requireRole([UserRole.ADMIN]),
  validate(courseSchema.create),
  CourseController.createCourse
);

// PUT update course - admin only
router.put(
  '/:id',
  requireRole([UserRole.ADMIN]),
  validate(courseSchema.update),
  CourseController.updateCourse
);

// DELETE course - admin only
router.delete(
  '/:id',
  requireRole([UserRole.ADMIN]),
  CourseController.deleteCourse
);

export default router;
