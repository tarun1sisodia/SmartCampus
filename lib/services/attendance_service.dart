import 'package:attedance__/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_session_model.dart';
import '../models/attendance_record_model.dart';

class AttendanceService {
  final supabase = Supabase.instance.client;

  // Create a new attendance session
  Future<AttendanceSessionModel> createAttendanceSession({
    required String classId,
    required DateTime date,
    String? startTime,
    String? endTime,
    required String createdBy,
  }) async {
    final response =
        await supabase
            .from('attendance_sessions')
            .insert({
              'class_id': classId,
              'date': date.toIso8601String().split('T')[0],
              'start_time': startTime,
              'end_time': endTime,
              'created_by': createdBy,
            })
            .select()
            .single();

    return AttendanceSessionModel.fromJson(response);
  }

  // Get attendance sessions for a class
  Future<List<AttendanceSessionModel>> getAttendanceSessionsForClass(
    String classId,
  ) async {
    final response = await supabase
        .from('attendance_sessions')
        .select()
        .eq('class_id', classId)
        .order('date', ascending: false);

    return response
        .map((json) => AttendanceSessionModel.fromJson(json))
        .toList();
  }

  // Get attendance records for a session
  Future<List<AttendanceRecordModel>> getAttendanceRecordsForSession(
    String sessionId,
  ) async {
    final response = await supabase
        .from('attendance_records')
        .select()
        .eq('session_id', sessionId);

    return response
        .map((json) => AttendanceRecordModel.fromJson(json))
        .toList();
  }

  // Mark attendance for a student
  Future<AttendanceRecordModel> markAttendance({
    required String sessionId,
    required String studentId,
    required String status,
    String? remarks,
  }) async {
    // Check if a record already exists
    final existingRecords = await supabase
        .from('attendance_records')
        .select()
        .eq('session_id', sessionId)
        .eq('student_id', studentId);

    if (existingRecords.isNotEmpty) {
      // Update existing record
      final response =
          await supabase
              .from('attendance_records')
              .update({
                'status': status,
                'remarks': remarks,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('session_id', sessionId)
              .eq('student_id', studentId)
              .select()
              .single();

      return AttendanceRecordModel.fromJson(response);
    } else {
      // Create new record
      final response =
          await supabase
              .from('attendance_records')
              .insert({
                'session_id': sessionId,
                'student_id': studentId,
                'status': status,
                'remarks': remarks,
              })
              .select()
              .single();

      return AttendanceRecordModel.fromJson(response);
    }
  }
  // Existing methods and properties

  Future<void> submitAttendanceRecords({
    required String sessionId,
    required List<StudentModel> students,
  }) async {
    // Implement the logic to submit attendance records to the backend or database
    // Example:
    for (var student in students) {
      // Submit each student's attendance record
      print(
        'Submitting attendance for ${student.name}: ${student.attendanceStatus}',
      );
    }
  }

  // Submit attendance for multiple students at once
  Future<void> submitBulkAttendance({
    required String sessionId,
    required List<Map<String, dynamic>> records,
  }) async {
    await supabase
        .from('attendance_records')
        .upsert(
          records
              .map(
                (record) => {
                  'session_id': sessionId,
                  'student_id': record['student_id'],
                  'status': record['status'],
                  'remarks': record['remarks'],
                },
              )
              .toList(),
          onConflict: 'session_id,student_id',
        );
  }

  // Get attendance statistics for a class
  Future<Map<String, dynamic>> getAttendanceStatsForClass(
    String classId,
  ) async {
    // Get total number of sessions
    final sessionsResponse = await supabase
        .from('attendance_sessions')
        .select('id')
        .eq('class_id', classId);

    final totalSessions = sessionsResponse.length;

    if (totalSessions == 0) {
      return {'totalSessions': 0, 'averageAttendance': 0.0};
    }

    // Get all attendance records for this class
    final recordsResponse = await supabase.rpc(
      'get_class_attendance_stats',
      params: {'class_id_param': classId},
    );

    return {
      'totalSessions': totalSessions,
      'averageAttendance': recordsResponse[0]['average_attendance'] ?? 0.0,
    };
  }
}
