import { Model } from '@nozbe/watermelondb'
import { field, date, readonly, text, children } from '@nozbe/watermelondb/decorators'

export class User extends Model {
  static table = 'users'

  @text('full_name') fullName!: string
  @text('email') email!: string
  @text('role') role!: string
  @text('department') department?: string
  @readonly @date('created_at') createdAt!: number
  @readonly @date('updated_at') updatedAt!: number
}

export class Class extends Model {
  static table = 'classes'

  @text('name') name!: string
  @text('section') section!: string
  @text('department') department!: string
  @text('course_id') courseId!: string
  @text('teacher_id') teacherId!: string
  @readonly @date('created_at') createdAt!: number
  
  @children('students') students!: any
  @children('attendance_sessions') sessions!: any
}

export class Student extends Model {
  static table = 'students'

  @text('name') name!: string
  @text('roll_number') rollNumber!: string
  @text('class_id') classId!: string
  @text('image_url') imageUrl?: string
  @readonly @date('created_at') createdAt!: number
}

export class AttendanceSession extends Model {
  static table = 'attendance_sessions'

  @text('class_id') classId!: string
  @text('date') date!: string
  @text('start_time') startTime?: string
  @text('end_time') endTime?: string
  @text('status') status!: string
  @text('created_by') createdBy!: string
  @readonly @date('created_at') createdAt!: number
  
  @children('attendance_records') records!: any
}

export class AttendanceRecord extends Model {
  static table = 'attendance_records'

  @text('session_id') sessionId!: string
  @text('student_id') studentId!: string
  @text('status') status!: string
  @text('remarks') remarks?: string
  @readonly @date('created_at') createdAt!: number
}
