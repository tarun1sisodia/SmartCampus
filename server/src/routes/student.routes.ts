import { Router } from 'express';
import StudentController from '../controllers/student.controller';
import { authenticateToken, requireRole } from '../middleware/auth';
import { UserRole } from '../types';
import validate from '../middleware/validate';
import studentSchema from '../validations/student.validation';
import { uploadProfilePicture, uploadCSV } from '../utils/upload';

const router = Router();

// Apply authentication to all student routes
router.use(authenticateToken);

// GET all students by course - accessible by admin and teachers
router.get(
  '/course/:courseId',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  StudentController.getStudentsByCourse
);

// GET single student by ID - accessible by admin and teachers
router.get(
  '/:id',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  StudentController.getStudent
);

// POST create new student - admin only
router.post(
  '/',
  requireRole([UserRole.ADMIN]),
  uploadProfilePicture,
  validate(studentSchema.create),
  StudentController.createStudent
);

// PUT update student - admin only
router.put(
  '/:id',
  requireRole([UserRole.ADMIN]),
  uploadProfilePicture,
  validate(studentSchema.update),
  StudentController.updateStudent
);

// DELETE student - admin only
router.delete(
  '/:id',
  requireRole([UserRole.ADMIN]),
  StudentController.deleteStudent
);

// POST import students from CSV - admin only
router.post(
  '/import/:courseId',
  requireRole([UserRole.ADMIN]),
  uploadCSV,
  StudentController.importStudents
);

// GET export students to CSV - admin and teachers
router.get(
  '/export/:courseId',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  StudentController.exportStudents
);

export default router;
