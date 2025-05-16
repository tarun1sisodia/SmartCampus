export interface User {
  id: string;
  email: string;
  role: UserRole;
  created_at: Date;
  updated_at: Date;
}

export enum UserRole {
  ADMIN = 'admin',
  TEACHER = 'teacher',
  USER = 'user'
}

export interface Course {
  id: string;
  name: string;
  code: string;
  description?: string;
  created_at: Date;
  updated_at: Date;
}

export interface Subject {
  id: string;
  name: string;
  code: string;
  course_id: string;
  semester: number;
  description?: string;
  created_at: Date;
  updated_at: Date;
}

export interface Student {
  id: string;
  name: string;
  roll_number: string;
  email: string;
  course_id: string;
  semester: number;
  section: string;
  profile_picture_url?: string;
  created_at: Date;
  updated_at: Date;
}

export interface AttendanceSession {
  id: string;
  subject_id: string;
  teacher_id: string;
  date: Date;
  start_time: Date;
  end_time: Date;
  created_at: Date;
  updated_at: Date;
}

export interface AttendanceRecord {
  id: string;
  session_id: string;
  student_id: string;
  status: AttendanceStatus;
  marked_by: string;
  marked_at: Date;
  created_at: Date;
  updated_at: Date;
}

export enum AttendanceStatus {
  PRESENT = 'present',
  ABSENT = 'absent',
  LATE = 'late',
  EXCUSED = 'excused'
}
