import { DatabaseService } from './database.service';
import { Course } from '../types';
import logger from '../utils/logger';

export class CourseService extends DatabaseService {
  constructor() {
    super('courses');
  }

  async createCourse(courseData: Partial<Course>) {
    try {
      const course = await this.create(courseData);
      logger.info('Course created successfully', { courseId: course.id });
      return course;
    } catch (error) {
      logger.error('Failed to create course', { error, courseData });
      throw error;
    }
  }

  async getCourseById(id: string) {
    try {
      const course = await this.findOne(id);
      if (!course) {
        throw new Error('Course not found');
      }
      return course;
    } catch (error) {
      logger.error('Failed to get course', { error, courseId: id });
      throw error;
    }
  }

  async getAllCourses() {
    try {
      const courses = await this.findMany();
      return courses;
    } catch (error) {
      logger.error('Failed to get courses', { error });
      throw error;
    }
  }

  async updateCourse(id: string, courseData: Partial<Course>) {
    try {
      const course = await this.update(id, courseData);
      logger.info('Course updated successfully', { courseId: id });
      return course;
    } catch (error) {
      logger.error('Failed to update course', { error, courseId: id, courseData });
      throw error;
    }
  }

  async deleteCourse(id: string) {
    try {
      await this.delete(id);
      logger.info('Course deleted successfully', { courseId: id });
      return true;
    } catch (error) {
      logger.error('Failed to delete course', { error, courseId: id });
      throw error;
    }
  }
}

export default new CourseService();
