export interface UserModel {
  id: string;
  email: string;
  fullName: string;
  role: 'teacher' | 'admin' | 'student';
  department?: string;
  imageUrl?: string;
  createdAt: string;
  updatedAt: string;
}

export interface StudentModel {
  id: string;
  name: string;
  rollNumber: string;
  classId: string;
  imageUrl?: string;
  attendanceStatus?: 'present' | 'absent' | 'late'; // Transient UI state
  createdAt: string;
  updatedAt: string;
}

export interface ClassModel {
  id: string;
  name: string;
  section: string;
  department: string;
  courseId: string;
  teacherId: string;
}

export interface AttendanceSessionModel {
  id: string;
  classId: string;
  date: string;
  startTime?: string;
  endTime?: string;
  status: 'active' | 'closed';
  createdBy: string;
  createdAt: string;
}

export interface AttendanceRecordModel {
  id: string;
  sessionId: string;
  studentId: string;
  status: 'present' | 'absent' | 'late';
  remarks?: string;
  createdAt: string;
}

export interface AttendanceStats {
  totalSessions: number;
  totalStudents: number;
  avgAttendance: number;
}
