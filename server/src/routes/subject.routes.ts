import { Router } from 'express';
import SubjectController from '../controllers/subject.controller';
import { authenticateToken, requireRole } from '../middleware/auth';
import { UserRole } from '../types';
import validate from '../middleware/validate';
import subjectSchema from '../validations/subject.validation';

const router = Router();

// Apply authentication to all subject routes
router.use(authenticateToken);

// GET all subjects - accessible by admin and teachers
router.get(
  '/',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  SubjectController.getAllSubjects
);

// GET subjects by course - accessible by admin and teachers
router.get(
  '/course/:courseId',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  SubjectController.getSubjectsByCourse
);

// GET single subject by ID - accessible by admin and teachers
router.get(
  '/:id',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  SubjectController.getSubject
);

// POST create new subject - admin only
router.post(
  '/',
  requireRole([UserRole.ADMIN]),
  validate(subjectSchema.create),
  SubjectController.createSubject
);

// PUT update subject - admin only
router.put(
  '/:id',
  requireRole([UserRole.ADMIN]),
  validate(subjectSchema.update),
  SubjectController.updateSubject
);

// DELETE subject - admin only
router.delete(
  '/:id',
  requireRole([UserRole.ADMIN]),
  SubjectController.deleteSubject
);

export default router;
