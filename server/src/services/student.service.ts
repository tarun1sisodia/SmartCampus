import { DatabaseService } from './database.service';
import { Student } from '../types';
import logger from '../utils/logger';
import { NotFoundError } from '../utils/error';
import supabase from '../utils/supabase';
import { createReadStream, createWriteStream } from 'fs';
import csv from 'csv-parse';
import { stringify } from 'csv-stringify/sync';
import path from 'path';

export class StudentService extends DatabaseService {
  constructor() {
    super('students');
  }

  async createStudent(studentData: Partial<Student>, profilePicture?: Express.Multer.File) {
    try {
      let profilePictureUrl: string | undefined;

      if (profilePicture) {
        // Upload profile picture to Supabase storage
        const { data, error } = await supabase.storage
          .from('profile-pictures')
          .upload(
            `${Date.now()}-${profilePicture.originalname}`,
            createReadStream(profilePicture.path),
            {
              contentType: profilePicture.mimetype,
              cacheControl: '3600'
            }
          );

        if (error) throw error;
        
        // Get public URL for the uploaded file
        const { data: { publicUrl } } = supabase.storage
          .from('profile-pictures')
          .getPublicUrl(data.path);

        profilePictureUrl = publicUrl;
      }

      const student = await this.create({
        ...studentData,
        profile_picture_url: profilePictureUrl
      });

      logger.info('Student created successfully', { studentId: student.id });
      return student;
    } catch (error) {
      logger.error('Failed to create student', { error, studentData });
      throw error;
    }
  }

  async getStudentById(id: string) {
    try {
      const { data: student, error } = await this.supabase
        .from(this.tableName)
        .select(`
          *,
          course:courses(id, name, code)
        `)
        .eq('id', id)
        .single();

      if (error) throw error;
      if (!student) throw new NotFoundError('Student not found');

      return student;
    } catch (error) {
      logger.error('Failed to get student', { error, studentId: id });
      throw error;
    }
  }

  async getStudentsByCourse(courseId: string) {
    try {
      const { data: students, error } = await this.supabase
        .from(this.tableName)
        .select(`
          *,
          course:courses(id, name, code)
        `)
        .eq('course_id', courseId);

      if (error) throw error;
      return students;
    } catch (error) {
      logger.error('Failed to get students by course', { error, courseId });
      throw error;
    }
  }

  async getAllStudents() {
    try {
      const { data: students, error } = await this.supabase
        .from(this.tableName)
        .select(`
          *,
          course:courses(id, name, code)
        `);

      if (error) throw error;
      return students;
    } catch (error) {
      logger.error('Failed to get all students', { error });
      throw error;
    }
  }

  async updateStudent(id: string, studentData: Partial<Student>, profilePicture?: Express.Multer.File) {
    try {
      const currentStudent = await this.getStudentById(id);

      let profilePictureUrl = currentStudent.profile_picture_url;

      if (profilePicture) {
        // Delete old profile picture if exists
        if (profilePictureUrl) {
          const oldFileName = profilePictureUrl.split('/').pop();
          if (oldFileName) {
            await supabase.storage
              .from('profile-pictures')
              .remove([oldFileName]);
          }
        }

        // Upload new profile picture
        const { data, error } = await supabase.storage
          .from('profile-pictures')
          .upload(
            `${Date.now()}-${profilePicture.originalname}`,
            createReadStream(profilePicture.path),
            {
              contentType: profilePicture.mimetype,
              cacheControl: '3600'
            }
          );

        if (error) throw error;
        
        // Get public URL for the uploaded file
        const { data: { publicUrl } } = supabase.storage
          .from('profile-pictures')
          .getPublicUrl(data.path);

        profilePictureUrl = publicUrl;
      }

      const student = await this.update(id, {
        ...studentData,
        profile_picture_url: profilePictureUrl
      });

      logger.info('Student updated successfully', { studentId: id });
      return student;
    } catch (error) {
      logger.error('Failed to update student', { error, studentId: id, studentData });
      throw error;
    }
  }

  async deleteStudent(id: string) {
    try {
      const student = await this.getStudentById(id);

      // Delete profile picture if exists
      if (student.profile_picture_url) {
        const fileName = student.profile_picture_url.split('/').pop();
        if (fileName) {
          await supabase.storage
            .from('profile-pictures')
            .remove([fileName]);
        }
      }

      await this.delete(id);
      logger.info('Student deleted successfully', { studentId: id });
      return true;
    } catch (error) {
      logger.error('Failed to delete student', { error, studentId: id });
      throw error;
    }
  }

  async importStudentsFromCSV(courseId: string, filePath: string): Promise<{ created: number; errors: string[] }> {
    const results = {
      created: 0,
      errors: [] as string[]
    };

    return new Promise((resolve, reject) => {
      const parser = csv.parse({
        columns: true,
        skip_empty_lines: true
      });

      const records: any[] = [];

      parser.on('readable', async () => {
        let record;
        while ((record = parser.read()) !== null) {
          records.push({
            ...record,
            course_id: courseId,
            created_at: new Date(),
            updated_at: new Date()
          });
        }
      });

      parser.on('error', (error) => {
        logger.error('CSV parsing error:', error);
        reject(error);
      });

      parser.on('end', async () => {
        try {
          for (const record of records) {
            try {
              await this.create(record);
              results.created++;
            } catch (error) {
              results.errors.push(`Failed to import student ${record.name}: ${error.message}`);
            }
          }
          resolve(results);
        } catch (error) {
          reject(error);
        }
      });

      createReadStream(filePath).pipe(parser);
    });
  }

  async exportStudentsToCSV(courseId: string): Promise<string> {
    try {
      const students = await this.getStudentsByCourse(courseId);
      
      const csvData = stringify(students, {
        header: true,
        columns: [
          'name',
          'roll_number',
          'email',
          'semester',
          'section',
          'created_at',
          'updated_at'
        ]
      });

      const fileName = `students-export-${Date.now()}.csv`;
      const filePath = path.join(__dirname, '../../uploads/csv', fileName);
      
      await new Promise((resolve, reject) => {
        const writeStream = createWriteStream(filePath);
        writeStream.write(csvData);
        writeStream.end();
        writeStream.on('finish', resolve);
        writeStream.on('error', reject);
      });

      return filePath;
    } catch (error) {
      logger.error('Failed to export students', { error, courseId });
      throw error;
    }
  }
}

export default new StudentService();
