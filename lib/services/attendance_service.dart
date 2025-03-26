import 'package:attedance__/models/attendance_record_model.dart';
import 'package:attedance__/models/attendance_session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final supabase = Supabase.instance.client;

  // Get attendance sessions for a class
  Future<List<AttendanceSessionModel>> getAttendanceSessions(
    String classId,
  ) async {
    try {
      final response = await supabase
          .from('attendance_sessions')
          .select()
          .eq('class_id', classId)
          .order('date', ascending: false);

      return response.map<AttendanceSessionModel>((json) {
        return AttendanceSessionModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw 'Failed to get attendance sessions: $e';
    }
  }

  // Get attendance sessions for a date range
  Future<List<AttendanceSessionModel>> getAttendanceSessionsForDateRange({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await supabase
          .from('attendance_sessions')
          .select()
          .eq('class_id', classId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date');

      return response.map<AttendanceSessionModel>((json) {
        return AttendanceSessionModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw 'Failed to get attendance sessions: $e';
    }
  }

  // Create a new attendance session
  Future<AttendanceSessionModel> createAttendanceSession({
    required String classId,
    required DateTime date,
    String? startTime,
    String? endTime,
    required String createdBy,
  }) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      final data = {
        'class_id': classId,
        'date': date.toIso8601String().split('T')[0],
        'start_time': startTime,
        'end_time': endTime,
        'created_by': currentUser.id,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await supabase
              .from('attendance_sessions')
              .insert(data)
              .select()
              .single();

      return AttendanceSessionModel.fromJson(response);
    } catch (e) {
      throw 'Failed to create attendance session: $e';
    }
  }

  // Get attendance records for a session
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
    String sessionId,
  ) async {
    try {
      final response = await supabase
          .from('attendance_records')
          .select()
          .eq('session_id', sessionId);

      return response.map<AttendanceRecordModel>((json) {
        return AttendanceRecordModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw 'Failed to get attendance records: $e';
    }
  }

  // Submit attendance for a student
  Future<void> submitAttendance({
    required String sessionId,
    required String studentId,
    required String status,
    String? remarks,
  }) async {
    try {
      // Check if record already exists
      final existingRecords = await supabase
          .from('attendance_records')
          .select()
          .eq('session_id', sessionId)
          .eq('student_id', studentId);

      final data = {
        'session_id': sessionId,
        'student_id': studentId,
        'status': status.toLowerCase(),
        'remarks': remarks,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingRecords.isNotEmpty) {
        // Update existing record
        await supabase
            .from('attendance_records')
            .update(data)
            .eq('session_id', sessionId)
            .eq('student_id', studentId);
      } else {
        // Create new record
        data['created_at'] = DateTime.now().toIso8601String();
        await supabase.from('attendance_records').insert(data);
      }
    } catch (e) {
      throw 'Failed to submit attendance: $e';
    }
  }

  // Get attendance statistics for a class
  Future<Map<String, dynamic>> getAttendanceStatsForClass(
    String classId,
  ) async {
    try {
      // Get total sessions
      final sessions = await getAttendanceSessions(classId);
      final totalSessions = sessions.length;

      if (totalSessions == 0) {
        return {'totalSessions': 0, 'averageAttendance': 0.0};
      }

      // Get all attendance records for all sessions
      final sessionIds = sessions.map((s) => s.id).toList();
      final response = await supabase
          .from('attendance_records')
          .select('status')
          .contains('session_id', sessionIds);

      // Count statuses
      int presentCount = 0;
      int absentCount = 0;
      int lateCount = 0;

      for (var record in response) {
        final status = record['status'] as String;
        if (status == 'present') {
          presentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'late') {
          lateCount++;
        }
      }

      // Calculate average attendance
      final totalRecords = response.length;
      final double averageAttendance =
          totalRecords > 0
              ? ((presentCount + (lateCount * 0.5)) / totalRecords) * 100
              : 0.0;

      return {
        'totalSessions': totalSessions,
        'presentCount': presentCount,
        'absentCount': absentCount,
        'lateCount': lateCount,
        'averageAttendance': averageAttendance,
      };
    } catch (e) {
      throw 'Failed to get attendance statistics: $e';
    }
  }

  // Get attendance statistics for a date range
  Future<Map<String, dynamic>> getAttendanceStatsForDateRange({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get sessions in date range
      final sessions = await getAttendanceSessionsForDateRange(
        classId: classId,
        startDate: startDate,
        endDate: endDate,
      );

      final totalSessions = sessions.length;

      if (totalSessions == 0) {
        return {
          'totalSessions': 0,
          'presentCount': 0,
          'absentCount': 0,
          'lateCount': 0,
          'averageAttendance': 0.0,
        };
      }

      // Get all attendance records for all sessions
      final sessionIds = sessions.map((s) => s.id).toList();
      final response = await supabase
          .from('attendance_records')
          .select('status')
          .inFilter('session_id', sessionIds);

      // Count statuses
      int presentCount = 0;
      int absentCount = 0;
      int lateCount = 0;

      for (var record in response) {
        final status = record['status'] as String;
        if (status == 'present') {
          presentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'late') {
          lateCount++;
        }
      }

      // Calculate average attendance
      final totalRecords = response.length;
      final double averageAttendance =
          totalRecords > 0
              ? ((presentCount + (lateCount * 0.5)) / totalRecords) * 100
              : 0.0;

      return {
        'totalSessions': totalSessions,
        'presentCount': presentCount,
        'absentCount': absentCount,
        'lateCount': lateCount,
        'averageAttendance': averageAttendance,
      };
    } catch (e) {
      throw 'Failed to get attendance statistics: $e';
    }
  }
  // Get attendance statistics for a student
  Future<Map<String, dynamic>> getAttendanceStatsForStudent({
    required String classId,
    required String studentId,
  }) async {
    try {
      // Get all sessions for the class
      final sessions = await getAttendanceSessions(classId);
      final totalSessions = sessions.length;

      if (totalSessions == 0) {
        return {
          'totalSessions': 0,
          'presentCount': 0,
          'absentCount': 0,
          'lateCount': 0,
          'attendancePercentage': 0.0,
        };
      }

      // Get all attendance records for the student
      final sessionIds = sessions.map((s) => s.id).toList();
      final response = await supabase
          .from('attendance_records')
          .select('status')
          .inFilter('session_id', sessionIds)
          .eq('student_id', studentId);

      // Count statuses
      int presentCount = 0;
      int absentCount = 0;
      int lateCount = 0;

      for (var record in response) {
        final status = record['status'] as String;
        if (status == 'present') {
          presentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'late') {
          lateCount++;
        }
      }

      // Calculate attendance percentage
      final double attendancePercentage =
          totalSessions > 0
              ? ((presentCount + (lateCount * 0.5)) / totalSessions) * 100
              : 0.0;

      return {
        'totalSessions': totalSessions,
        'presentCount': presentCount,
        'absentCount': absentCount,
        'lateCount': lateCount,
        'attendancePercentage': attendancePercentage,
      };
    } catch (e) {
      throw 'Failed to get student attendance statistics: $e';
    }
  }

  // Get attendance statistics for a student in a date range
  Future<Map<String, dynamic>> getAttendanceStatsForStudentInDateRange({
    required String classId,
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get sessions in date range
      final sessions = await getAttendanceSessionsForDateRange(
        classId: classId,
        startDate: startDate,
        endDate: endDate,
      );

      final totalSessions = sessions.length;

      if (totalSessions == 0) {
        return {
          'totalSessions': 0,
          'presentCount': 0,
          'absentCount': 0,
          'lateCount': 0,
          'attendancePercentage': 0.0,
        };
      }

      // Get all attendance records for the student
      final sessionIds = sessions.map((s) => s.id).toList();
      final response = await supabase
          .from('attendance_records')
          .select('status')
          .inFilter('session_id', sessionIds)
          .eq('student_id', studentId);

      // Count statuses
      int presentCount = 0;
      int absentCount = 0;
      int lateCount = 0;

      for (var record in response) {
        final status = record['status'] as String;
        if (status == 'present') {
          presentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'late') {
          lateCount++;
        }
      }

      // Calculate attendance percentage
      final double attendancePercentage =
          totalSessions > 0
              ? ((presentCount + (lateCount * 0.5)) / totalSessions) * 100
              : 0.0;

      return {
        'totalSessions': totalSessions,
        'presentCount': presentCount,
        'absentCount': absentCount,
        'lateCount': lateCount,
        'attendancePercentage': attendancePercentage,
      };
    } catch (e) {
      throw 'Failed to get student attendance statistics: $e';
    }
  }

  // Get student attendance history
  Future<List<Map<String, dynamic>>> getStudentAttendanceHistory({
    required String classId,
    required String studentId,
  }) async {
    try {
      // Get all sessions for the class
      final sessions = await getAttendanceSessions(classId);

      final history = <Map<String, dynamic>>[];

      for (var session in sessions) {
        // Get attendance record for this session
        final response =
            await supabase
                .from('attendance_records')
                .select()
                .eq('session_id', session.id)
                .eq('student_id', studentId)
                .maybeSingle();

        if (response != null) {
          history.add({
            'session': session,
            'status': response['status'],
            'remarks': response['remarks'],
          });
        } else {
          // No record found, mark as not recorded
          history.add({
            'session': session,
            'status': 'not_recorded',
            'remarks': null,
          });
        }
      }

      return history;
    } catch (e) {
      throw 'Failed to get student attendance history: $e';
    }
  }

  // Get attendance status for a specific session
  Future<String> getAttendanceStatusForSession({
    required String sessionId,
    required String studentId,
  }) async {
    try {
      final response =
          await supabase
              .from('attendance_records')
              .select('status')
              .eq('session_id', sessionId)
              .eq('student_id', studentId)
              .maybeSingle();

      if (response != null) {
        return response['status'];
      } else {
        return 'not_recorded';
      }
    } catch (e) {
      throw 'Failed to get attendance status: $e';
    }
  }

  // Delete an attendance session
  Future<void> deleteAttendanceSession(String sessionId) async {
    try {
      // First delete all attendance records for this session
      await supabase
          .from('attendance_records')
          .delete()
          .eq('session_id', sessionId);

      // Then delete the session
      await supabase.from('attendance_sessions').delete().eq('id', sessionId);
    } catch (e) {
      throw 'Failed to delete attendance session: $e';
    }
  }

  // Add this method to the AttendanceService class
  Future<List<AttendanceRecordModel>> getAttendanceRecordsForSession(
    String sessionId,
  ) async {
    try {
      final response = await supabase
          .from('attendance_records')
          .select()
          .eq('session_id', sessionId);

      return response.map<AttendanceRecordModel>((json) {
        return AttendanceRecordModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw 'Failed to get attendance records: $e';
    }
  }

  // Add this method for bulk attendance submission
  Future<void> submitBulkAttendance({
    required String sessionId,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      for (var record in records) {
        await submitAttendance(
          sessionId: sessionId,
          studentId: record['student_id'],
          status: record['status'],
          remarks: record['remarks'],
        );
      }
    } catch (e) {
      throw 'Failed to submit bulk attendance: $e';
    }
  }
}
