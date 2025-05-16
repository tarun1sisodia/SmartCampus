import { DatabaseService } from './database.service';
import { Subject } from '../types';
import logger from '../utils/logger';
import { NotFoundError } from '../utils/error';

export class SubjectService extends DatabaseService {
  constructor() {
    super('subjects');
  }

  async createSubject(subjectData: Partial<Subject>) {
    try {
      // Verify course exists before creating subject
      const { data: course } = await this.supabase
        .from('courses')
        .select('id')
        .eq('id', subjectData.course_id)
        .single();

      if (!course) {
        throw new NotFoundError('Course not found');
      }

      const subject = await this.create(subjectData);
      logger.info('Subject created successfully', { subjectId: subject.id });
      return subject;
    } catch (error) {
      logger.error('Failed to create subject', { error, subjectData });
      throw error;
    }
  }

  async getSubjectById(id: string) {
    try {
      const { data: subject, error } = await this.supabase
        .from(this.tableName)
        .select(`
          *,
          course:courses(id, name, code)
        `)
        .eq('id', id)
        .single();

      if (error) throw error;
      if (!subject) throw new NotFoundError('Subject not found');

      return subject;
    } catch (error) {
      logger.error('Failed to get subject', { error, subjectId: id });
      throw error;
    }
  }

  async getSubjectsByCourse(courseId: string) {
    try {
      const { data: subjects, error } = await this.supabase
        .from(this.tableName)
        .select(`
          *,
          course:courses(id, name, code)
        `)
        .eq('course_id', courseId);

      if (error) throw error;
      return subjects;
    } catch (error) {
      logger.error('Failed to get subjects by course', { error, courseId });
      throw error;
    }
  }

  async getAllSubjects() {
    try {
      const { data: subjects, error } = await this.supabase
        .from(this.tableName)
        .select(`
          *,
          course:courses(id, name, code)
        `);

      if (error) throw error;
      return subjects;
    } catch (error) {
      logger.error('Failed to get all subjects', { error });
      throw error;
    }
  }

  async updateSubject(id: string, subjectData: Partial<Subject>) {
    try {
      if (subjectData.course_id) {
        // Verify course exists if course_id is being updated
        const { data: course } = await this.supabase
          .from('courses')
          .select('id')
          .eq('id', subjectData.course_id)
          .single();

        if (!course) {
          throw new NotFoundError('Course not found');
        }
      }

      const subject = await this.update(id, subjectData);
      logger.info('Subject updated successfully', { subjectId: id });
      return subject;
    } catch (error) {
      logger.error('Failed to update subject', { error, subjectId: id, subjectData });
      throw error;
    }
  }

  async deleteSubject(id: string) {
    try {
      await this.delete(id);
      logger.info('Subject deleted successfully', { subjectId: id });
      return true;
    } catch (error) {
      logger.error('Failed to delete subject', { error, subjectId: id });
      throw error;
    }
  }
}

export default new SubjectService();
