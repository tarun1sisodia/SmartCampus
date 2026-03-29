import { appSchema, tableSchema } from '@nozbe/watermelondb'

export default appSchema({
  version: 1,
  tables: [
    tableSchema({
      name: 'users',
      columns: [
        { name: 'full_name', type: 'string' },
        { name: 'email', type: 'string' },
        { name: 'role', type: 'string' },
        { name: 'department', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ]
    }),
    tableSchema({
      name: 'classes',
      columns: [
        { name: 'name', type: 'string' },
        { name: 'section', type: 'string' },
        { name: 'department', type: 'string' },
        { name: 'course_id', type: 'string' },
        { name: 'teacher_id', type: 'string', isIndexed: true },
        { name: 'created_at', type: 'number' },
      ]
    }),
    tableSchema({
      name: 'students',
      columns: [
        { name: 'name', type: 'string' },
        { name: 'roll_number', type: 'string', isIndexed: true },
        { name: 'class_id', type: 'string', isIndexed: true },
        { name: 'image_url', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
      ]
    }),
    tableSchema({
      name: 'attendance_sessions',
      columns: [
        { name: 'class_id', type: 'string', isIndexed: true },
        { name: 'date', type: 'string' },
        { name: 'start_time', type: 'string', isOptional: true },
        { name: 'end_time', type: 'string', isOptional: true },
        { name: 'status', type: 'string' },
        { name: 'created_by', type: 'string' },
        { name: 'created_at', type: 'number' },
      ]
    }),
    tableSchema({
      name: 'attendance_records',
      columns: [
        { name: 'session_id', type: 'string', isIndexed: true },
        { name: 'student_id', type: 'string', isIndexed: true },
        { name: 'status', type: 'string' },
        { name: 'remarks', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
      ]
    }),
  ]
})
