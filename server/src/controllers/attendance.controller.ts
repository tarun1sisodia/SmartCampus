import { Request, Response } from 'express';
import attendanceService from '../services/attendance.service';
import logger from '../utils/logger';
import { NotFoundError, BadRequestError } from '../utils/error';
import { AttendanceStatus } from '../types';

export class AttendanceController {
  static async createSession(req: Request, res: Response) {
    try {
      const sessionData = req.body;
      const session = await attendanceService.createSession(sessionData);
      
      return res.status(201).json({
        status: 'success',
        data: session
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        return res.status(404).json({
          status: 'error',
          message: error.message
        });
      }

      logger.error('Create attendance session error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to create attendance session'
      });
    }
  }

  static async getSession(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const session = await attendanceService.getSessionById(id);
      
      return res.status(200).json({
        status: 'success',
        data: session
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        return res.status(404).json({
          status: 'error',
          message: error.message
        });
      }

      logger.error('Get attendance session error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch attendance session'
      });
    }
  }

  static async getSessionsBySubject(req: Request, res: Response) {
    try {
      const { subjectId } = req.params;
      const { startDate, endDate } = req.query;
      
      const sessions = await attendanceService.getSessionsBySubject(
        subjectId,
        startDate ? new Date(startDate as string) : undefined,
        endDate ? new Date(endDate as string) : undefined
      );
      
      return res.status(200).json({
        status: 'success',
        data: sessions
      });
    } catch (error) {
      logger.error('Get sessions by subject error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch attendance sessions'
      });
    }
  }

  static async markAttendance(req: Request, res: Response) {
    try {
      const { sessionId, studentId } = req.params;
      const { status } = req.body;
      const markedBy = req.user!.id;

      if (!Object.values(AttendanceStatus).includes(status)) {
        throw new BadRequestError('Invalid attendance status');
      }

      const record = await attendanceService.markAttendance(
        sessionId,
        studentId,
        status,
        markedBy
      );
      
      return res.status(200).json({
        status: 'success',
        data: record
      });
    } catch (error) {
      if (error instanceof BadRequestError) {
        return res.status(400).json({
          status: 'error',
          message: error.message
        });
      }

      logger.error('Mark attendance error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to mark attendance'
      });
    }
  }

  static async getSessionAttendance(req: Request, res: Response) {
    try {
      const { sessionId } = req.params;
      const records = await attendanceService.getSessionAttendance(sessionId);
      
      return res.status(200).json({
        status: 'success',
        data: records
      });
    } catch (error) {
      logger.error('Get session attendance error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch attendance records'
      });
    }
  }

  static async getStudentAttendance(req: Request, res: Response) {
    try {
      const { studentId } = req.params;
      const { subjectId, startDate, endDate } = req.query;
      
      const records = await attendanceService.getStudentAttendance(
        studentId,
        subjectId as string,
        startDate ? new Date(startDate as string) : undefined,
        endDate ? new Date(endDate as string) : undefined
      );
      
      return res.status(200).json({
        status: 'success',
        data: records
      });
    } catch (error) {
      logger.error('Get student attendance error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch student attendance'
      });
    }
  }

  static async generateReport(req: Request, res: Response) {
    try {
      const { subjectId } = req.params;
      const { startDate, endDate } = req.query;
      
      const report = await attendanceService.generateAttendanceReport(
        subjectId,
        startDate ? new Date(startDate as string) : undefined,
        endDate ? new Date(endDate as string) : undefined
      );
      
      return res.status(200).json({
        status: 'success',
        data: report
      });
    } catch (error) {
      logger.error('Generate attendance report error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to generate attendance report'
      });
    }
  }
}

export default AttendanceController;
