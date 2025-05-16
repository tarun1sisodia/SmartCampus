import { Request, Response } from 'express';
import courseService from '../services/course.service';
import logger from '../utils/logger';

export class CourseController {
  static async createCourse(req: Request, res: Response) {
    try {
      const courseData = req.body;
      const course = await courseService.createCourse(courseData);
      
      return res.status(201).json({
        status: 'success',
        data: course
      });
    } catch (error) {
      logger.error('Create course error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to create course'
      });
    }
  }

  static async getCourse(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const course = await courseService.getCourseById(id);
      
      return res.status(200).json({
        status: 'success',
        data: course
      });
    } catch (error) {
      logger.error('Get course error:', error);
      return res.status(404).json({
        status: 'error',
        message: 'Course not found'
      });
    }
  }

  static async getAllCourses(req: Request, res: Response) {
    try {
      const courses = await courseService.getAllCourses();
      
      return res.status(200).json({
        status: 'success',
        data: courses
      });
    } catch (error) {
      logger.error('Get all courses error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch courses'
      });
    }
  }

  static async updateCourse(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const courseData = req.body;
      const course = await courseService.updateCourse(id, courseData);
      
      return res.status(200).json({
        status: 'success',
        data: course
      });
    } catch (error) {
      logger.error('Update course error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to update course'
      });
    }
  }

  static async deleteCourse(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await courseService.deleteCourse(id);
      
      return res.status(200).json({
        status: 'success',
        message: 'Course deleted successfully'
      });
    } catch (error) {
      logger.error('Delete course error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to delete course'
      });
    }
  }
}

export default CourseController;
