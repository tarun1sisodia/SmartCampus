import { DatabaseService } from './database.service';
import { AttendanceSession, AttendanceRecord, AttendanceStatus } from '../types';
import logger from '../utils/logger';
import { NotFoundError, BadRequestError } from '../utils/error';
import supabase from '../utils/supabase';

export class AttendanceService extends DatabaseService {
  private sessionTable: string;
  private recordTable: string;

  constructor() {
    super('attendance_sessions');
    this.sessionTable = 'attendance_sessions';
    this.recordTable = 'attendance_records';
  }

  async createSession(sessionData: Partial<AttendanceSession>) {
    try {
      // Verify subject exists
      const { data: subject } = await supabase
        .from('subjects')
        .select('id')
        .eq('id', sessionData.subject_id)
        .single();

      if (!subject) {
        throw new NotFoundError('Subject not found');
      }

      // Create session
      const { data: session, error } = await supabase
        .from(this.sessionTable)
        .insert(sessionData)
        .select()
        .single();

      if (error) throw error;

      // Get all students for the course
      const { data: students } = await supabase
        .from('students')
        .select('id')
        .eq('course_id', subject.course_id);

      if (students && students.length > 0) {
        // Create attendance records for all students
        const records = students.map(student => ({
          session_id: session.id,
          student_id: student.id,
          status: AttendanceStatus.ABSENT,
          marked_by: sessionData.teacher_id
        }));

        const { error: recordError } = await supabase
          .from(this.recordTable)
          .insert(records);

        if (recordError) throw recordError;
      }

      logger.info('Attendance session created successfully', { sessionId: session.id });
      return session;
    } catch (error) {
      logger.error('Failed to create attendance session', { error, sessionData });
      throw error;
    }
  }

  async getSessionById(id: string) {
    try {
      const { data: session, error } = await supabase
        .from(this.sessionTable)
        .select(`
          *,
          subject:subjects(
            id,
            name,
            code,
            course:courses(id, name, code)
          ),
          teacher:users(id, email, full_name)
        `)
        .eq('id', id)
        .single();

      if (error) throw error;
      if (!session) throw new NotFoundError('Attendance session not found');

      return session;
    } catch (error) {
      logger.error('Failed to get attendance session', { error, sessionId: id });
      throw error;
    }
  }

  async getSessionsBySubject(subjectId: string, startDate?: Date, endDate?: Date) {
    try {
      let query = supabase
        .from(this.sessionTable)
        .select(`
          *,
          subject:subjects(
            id,
            name,
            code,
            course:courses(id, name, code)
          ),
          teacher:users(id, email, full_name)
        `)
        .eq('subject_id', subjectId);

      if (startDate) {
        query = query.gte('date', startDate.toISOString());
      }
      if (endDate) {
        query = query.lte('date', endDate.toISOString());
      }

      const { data: sessions, error } = await query;

      if (error) throw error;
      return sessions;
    } catch (error) {
      logger.error('Failed to get attendance sessions by subject', { error, subjectId });
      throw error;
    }
  }

  async markAttendance(sessionId: string, studentId: string, status: AttendanceStatus, markedBy: string) {
    try {
      // Verify session exists and is not in the past
      const session = await this.getSessionById(sessionId);
      const now = new Date();
      
      if (new Date(session.end_time) < now) {
        throw new BadRequestError('Cannot mark attendance for past sessions');
      }

      const { data: record, error } = await supabase
        .from(this.recordTable)
        .update({
          status,
          marked_by: markedBy,
          marked_at: now.toISOString()
        })
        .eq('session_id', sessionId)
        .eq('student_id', studentId)
        .select()
        .single();

      if (error) throw error;

      logger.info('Attendance marked successfully', {
        sessionId,
        studentId,
        status
      });

      return record;
    } catch (error) {
      logger.error('Failed to mark attendance', {
        error,
        sessionId,
        studentId,
        status
      });
      throw error;
    }
  }

  async getSessionAttendance(sessionId: string) {
    try {
      const { data: records, error } = await supabase
        .from(this.recordTable)
        .select(`
          *,
          student:students(
            id,
            name,
            roll_number,
            email,
            profile_picture_url
          ),
          marked_by:users(id, email, full_name)
        `)
        .eq('session_id', sessionId);

      if (error) throw error;
      return records;
    } catch (error) {
      logger.error('Failed to get session attendance', { error, sessionId });
      throw error;
    }
  }

  async getStudentAttendance(studentId: string, subjectId?: string, startDate?: Date, endDate?: Date) {
    try {
      let query = supabase
        .from(this.recordTable)
        .select(`
          *,
          session:${this.sessionTable}(
            id,
            date,
            start_time,
            end_time,
            subject:subjects(id, name, code)
          )
        `)
        .eq('student_id', studentId);

      if (subjectId) {
        query = query.eq('session.subject_id', subjectId);
      }
      if (startDate) {
        query = query.gte('session.date', startDate.toISOString());
      }
      if (endDate) {
        query = query.lte('session.date', endDate.toISOString());
      }

      const { data: records, error } = await query;

      if (error) throw error;
      return records;
    } catch (error) {
      logger.error('Failed to get student attendance', {
        error,
        studentId,
        subjectId
      });
      throw error;
    }
  }

  async generateAttendanceReport(subjectId: string, startDate?: Date, endDate?: Date) {
    try {
      // Get all sessions for the subject
      const sessions = await this.getSessionsBySubject(subjectId, startDate, endDate);
      
      // Get all students for the subject's course
      const { data: subject } = await supabase
        .from('subjects')
        .select('course_id')
        .eq('id', subjectId)
        .single();

      const { data: students } = await supabase
        .from('students')
        .select('*')
        .eq('course_id', subject.course_id);

      // Calculate attendance statistics for each student
      const report = await Promise.all(students.map(async (student) => {
        const records = await this.getStudentAttendance(
          student.id,
          subjectId,
          startDate,
          endDate
        );

        const totalSessions = sessions.length;
        const presentCount = records.filter(r => r.status === AttendanceStatus.PRESENT).length;
        const absentCount = records.filter(r => r.status === AttendanceStatus.ABSENT).length;
        const lateCount = records.filter(r => r.status === AttendanceStatus.LATE).length;
        const excusedCount = records.filter(r => r.status === AttendanceStatus.EXCUSED).length;

        return {
          student: {
            id: student.id,
            name: student.name,
            roll_number: student.roll_number
          },
          statistics: {
            totalSessions,
            presentCount,
            absentCount,
            lateCount,
            excusedCount,
            attendancePercentage: (presentCount / totalSessions) * 100
          }
        };
      }));

      return report;
    } catch (error) {
      logger.error('Failed to generate attendance report', {
        error,
        subjectId
      });
      throw error;
    }
  }
}

export default new AttendanceService();
