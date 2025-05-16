import { Request, Response } from 'express';
import subjectService from '../services/subject.service';
import logger from '../utils/logger';
import { NotFoundError } from '../utils/error';

export class SubjectController {
  static async createSubject(req: Request, res: Response) {
    try {
      const subjectData = req.body;
      const subject = await subjectService.createSubject(subjectData);
      
      return res.status(201).json({
        status: 'success',
        data: subject
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        return res.status(404).json({
          status: 'error',
          message: error.message
        });
      }
      
      logger.error('Create subject error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to create subject'
      });
    }
  }

  static async getSubject(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const subject = await subjectService.getSubjectById(id);
      
      return res.status(200).json({
        status: 'success',
        data: subject
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        return res.status(404).json({
          status: 'error',
          message: error.message
        });
      }

      logger.error('Get subject error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch subject'
      });
    }
  }

  static async getSubjectsByCourse(req: Request, res: Response) {
    try {
      const { courseId } = req.params;
      const subjects = await subjectService.getSubjectsByCourse(courseId);
      
      return res.status(200).json({
        status: 'success',
        data: subjects
      });
    } catch (error) {
      logger.error('Get subjects by course error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch subjects'
      });
    }
  }

  static async getAllSubjects(req: Request, res: Response) {
    try {
      const subjects = await subjectService.getAllSubjects();
      
      return res.status(200).json({
        status: 'success',
        data: subjects
      });
    } catch (error) {
      logger.error('Get all subjects error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch subjects'
      });
    }
  }

  static async updateSubject(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const subjectData = req.body;
      const subject = await subjectService.updateSubject(id, subjectData);
      
      return res.status(200).json({
        status: 'success',
        data: subject
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        return res.status(404).json({
          status: 'error',
          message: error.message
        });
      }

      logger.error('Update subject error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to update subject'
      });
    }
  }

  static async deleteSubject(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await subjectService.deleteSubject(id);
      
      return res.status(200).json({
        status: 'success',
        message: 'Subject deleted successfully'
      });
    } catch (error) {
      logger.error('Delete subject error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to delete subject'
      });
    }
  }
}

export default SubjectController;
