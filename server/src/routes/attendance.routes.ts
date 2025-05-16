import { Router } from 'express';
import AttendanceController from '../controllers/attendance.controller';
import { authenticateToken, requireRole } from '../middleware/auth';
import { UserRole } from '../types';
import validate from '../middleware/validate';
import attendanceSchema from '../validations/attendance.validation';

const router = Router();

// Apply authentication to all attendance routes
router.use(authenticateToken);

// Create attendance session - teachers and admin
router.post(
  '/sessions',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  validate(attendanceSchema.createSession),
  AttendanceController.createSession
);

// Get single session
router.get(
  '/sessions/:id',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  AttendanceController.getSession
);

// Get sessions by subject
router.get(
  '/sessions/subject/:subjectId',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  validate(attendanceSchema.dateRange),
  AttendanceController.getSessionsBySubject
);

// Mark attendance for a student in a session
router.post(
  '/sessions/:sessionId/students/:studentId',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  validate(attendanceSchema.markAttendance),
  AttendanceController.markAttendance
);

// Get attendance records for a session
router.get(
  '/sessions/:sessionId/records',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  AttendanceController.getSessionAttendance
);

// Get attendance records for a student
router.get(
  '/students/:studentId',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  validate(attendanceSchema.dateRange),
  AttendanceController.getStudentAttendance
);

// Generate attendance report for a subject
router.get(
  '/reports/subject/:subjectId',
  requireRole([UserRole.ADMIN, UserRole.TEACHER]),
  validate(attendanceSchema.dateRange),
  AttendanceController.generateReport
);

export default router;
