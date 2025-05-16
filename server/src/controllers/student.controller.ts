import { Request, Response } from 'express';
import studentService from '../services/student.service';
import logger from '../utils/logger';
import { NotFoundError } from '../utils/error';
import fs from 'fs';

export class StudentController {
  static async createStudent(req: Request, res: Response) {
    try {
      const studentData = req.body;
      const profilePicture = req.file;

      const student = await studentService.createStudent(studentData, profilePicture);
      
      // Clean up uploaded file after processing
      if (profilePicture) {
        fs.unlink(profilePicture.path, (err) => {
          if (err) logger.error('Error deleting uploaded file:', err);
        });
      }

      return res.status(201).json({
        status: 'success',
        data: student
      });
    } catch (error) {
      logger.error('Create student error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to create student'
      });
    }
  }

  static async getStudent(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const student = await studentService.getStudentById(id);
      
      return res.status(200).json({
        status: 'success',
        data: student
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        return res.status(404).json({
          status: 'error',
          message: error.message
        });
      }

      logger.error('Get student error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch student'
      });
    }
  }

  static async getStudentsByCourse(req: Request, res: Response) {
    try {
      const { courseId } = req.params;
      const students = await studentService.getStudentsByCourse(courseId);
      
      return res.status(200).json({
        status: 'success',
        data: students
      });
    } catch (error) {
      logger.error('Get students by course error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch students'
      });
    }
  }

  static async updateStudent(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const studentData = req.body;
      const profilePicture = req.file;

      const student = await studentService.updateStudent(id, studentData, profilePicture);
      
      // Clean up uploaded file after processing
      if (profilePicture) {
        fs.unlink(profilePicture.path, (err) => {
          if (err) logger.error('Error deleting uploaded file:', err);
        });
      }

      return res.status(200).json({
        status: 'success',
        data: student
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        return res.status(404).json({
          status: 'error',
          message: error.message
        });
      }

      logger.error('Update student error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to update student'
      });
    }
  }

  static async deleteStudent(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await studentService.deleteStudent(id);
      
      return res.status(200).json({
        status: 'success',
        message: 'Student deleted successfully'
      });
    } catch (error) {
      logger.error('Delete student error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to delete student'
      });
    }
  }

  static async importStudents(req: Request, res: Response) {
    try {
      const { courseId } = req.params;
      const csvFile = req.file;

      if (!csvFile) {
        return res.status(400).json({
          status: 'error',
          message: 'No CSV file provided'
        });
      }

      const results = await studentService.importStudentsFromCSV(courseId, csvFile.path);

      // Clean up uploaded file after processing
      fs.unlink(csvFile.path, (err) => {
        if (err) logger.error('Error deleting uploaded file:', err);
      });

      return res.status(200).json({
        status: 'success',
        data: results
      });
    } catch (error) {
      logger.error('Import students error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to import students'
      });
    }
  }

  static async exportStudents(req: Request, res: Response) {
    try {
      const { courseId } = req.params;
      const filePath = await studentService.exportStudentsToCSV(courseId);

      res.download(filePath, (err) => {
        if (err) {
          logger.error('Error sending file:', err);
        }
        // Clean up file after sending
        fs.unlink(filePath, (err) => {
          if (err) logger.error('Error deleting exported file:', err);
        });
      });
    } catch (error) {
      logger.error('Export students error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to export students'
      });
    }
  }
}

export default StudentController;
