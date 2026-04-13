import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/attendance_record_model.dart';
import '../models/attendance_session_model.dart';
import '../models/class_model.dart';
import 'local_db_service.dart';
import 'connectivity_service.dart';

class AttendanceService {
  final supabase = Supabase.instance.client;
  static const int defaultSessionFetchLimit = 60;
  static const String _sessionSelectFields =
      'id, class_id, date, start_time, end_time, created_by, created_at, updated_at, status, closed_at';
  static const String _attendanceRecordSelectFields =
      'id, session_id, student_id, status, remarks, created_at, updated_at';

  // Fetch attendance statistics from Edge Function (Scaling)
  Future<Map<String, dynamic>> getAttendanceStatsFromEdge({
    required String classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('Invoking calculate-attendance-stats Edge Function for class: $classId');
      
      final session = supabase.auth.currentSession;
      if (session == null) {
        debugPrint('Edge Function Diagnostic: No active session found.');
        throw 'Session expired or not found. Please log in again.';
      }

      // Diagnostic logging
      final expiry = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      final isExpired = expiry.isBefore(DateTime.now());
      debugPrint('Edge Function Diagnostic: JWT Session Expiry: $expiry (Is Expired: $isExpired)');
      debugPrint('Edge Function Diagnostic: Current Time: ${DateTime.now()}');

      final response = await supabase.functions.invoke(
        'calculate-attendance-stats',
        body: {
          'classId': classId,
          'startDate': startDate?.toIso8601String().split('T')[0],
          'endDate': endDate?.toIso8601String().split('T')[0],
        },
      );

      if (response.status != 200) {
        throw 'Edge Function error: ${response.data}';
      }

      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error calling Edge Function: $e');
      throw 'Failed to get high-performance statistics: $e';
    }
  }

  // Get attendance sessions for a class
  Future<List<AttendanceSessionModel>> getAttendanceSessions(
    String classId,
    {
    int limit = defaultSessionFetchLimit,
    int offset = 0,
  }
  ) async {
    try {
      //print('Fetching attendance sessions for class: $classId');
      final response = await supabase
          .from('attendance_sessions')
          .select(_sessionSelectFields)
          .eq('class_id', classId)
          .range(offset, offset + limit - 1)
          .order('date', ascending: false);

      return response.map<AttendanceSessionModel>((json) {
        return AttendanceSessionModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error getting attendance sessions: $e');
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
      //print('Fetching attendance sessions for date range: $startDate to $endDate');
      final response = await supabase
          .from('attendance_sessions')
          .select(_sessionSelectFields)
          .eq('class_id', classId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date');

      return response.map<AttendanceSessionModel>((json) {
        return AttendanceSessionModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error getting attendance sessions for date range: $e');
      throw 'Failed to get attendance sessions: $e';
    }
  }

  // Create a new attendance session by class id
  Future<AttendanceSessionModel> createAttendanceSession({
    required String classId,
    required DateTime date,
    String? startTime,
    String? endTime,
    required String createdBy,
  }) async {
    try {
      //print('Creating new attendance session for class: $classId');
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Your Are not Authorize', 'First Register or Login');
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

      try {
        final response = await supabase
            .from('attendance_sessions')
            .insert(data)
            .select(_sessionSelectFields)
            .single();

        return AttendanceSessionModel.fromJson(response);
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          // Conflict: Session already exists for this class and date
          final String dateOnly = date.toIso8601String().split('T')[0];
          debugPrint('Session already exists, fetching existing session for $classId on $dateOnly');
          
          final existingResponse = await supabase
              .from('attendance_sessions')
              .select(_sessionSelectFields)
              .eq('class_id', classId)
              .eq('date', dateOnly)
              .single();
              
          return AttendanceSessionModel.fromJson(existingResponse);
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error creating attendance session: $e');
      Get.snackbar('Failed to Create Attendance Session', 'Session might already exist or server error.');
      throw 'Failed to create attendance session: $e';
    }
  }

  // Deletes multiple attendance sessions and their records (Batched)
  Future<void> deleteSessions(List<String> sessionIds) async {
    try {
      if (sessionIds.isEmpty) return;
      debugPrint('Deleting ${sessionIds.length} attendance sessions');

      // 1. Delete all attendance records for these sessions in one batch
      await supabase
          .from('attendance_records')
          .delete()
          .inFilter('session_id', sessionIds);

      // 2. Delete the sessions themselves in one batch
      await supabase
          .from('attendance_sessions')
          .delete()
          .inFilter('id', sessionIds);

      debugPrint('Batch deletion successful');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw 'Failed to delete sessions: $e';
    }
  }

  // Deletes an attendance session by its ID.
  Future<void> deleteSession(String sessionId) async {
    await deleteSessions([sessionId]);
  }

  // Get attendance records for a session
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
    String sessionId,
  ) async {
    try {
      //print('Fetching attendance records for session: $sessionId');
      final response = await supabase
          .from('attendance_records')
          .select(_attendanceRecordSelectFields)
          .eq('session_id', sessionId);

      return response.map<AttendanceRecordModel>((json) {
        return AttendanceRecordModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error getting attendance records: $e');
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
      //print(
      // 'Submitting attendance for student: $studentId in session: $sessionId');
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
        // existing record
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
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error submitting attendance: $e');
      throw 'Failed to submit attendance: $e';
    }
  }

  // Closes an attendance session by updating its status
  Future<void> closeAttendanceSession(String sessionId) async {
    try {
      //print('Closing attendance session: $sessionId');

      // the session with a closed status
      await supabase.from('attendance_sessions').update({
        'status': 'closed',
        'closed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);

      //print('Session closed successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error closing attendance session: $e');
      throw 'Failed to close attendance session: $e';
    }
  }

  // Get attendance statistics for multiple classes (Batched)
  Future<Map<String, Map<String, dynamic>>> getAttendanceStatsForClasses(
    List<String> classIds,
  ) async {
    try {
      if (classIds.isEmpty) return {};

      final stats = <String, Map<String, dynamic>>{};
      await Future.wait(classIds.map((id) async {
        stats[id] = await getAttendanceStatsForClass(id);
      }));

      return stats;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw 'Failed to get batched attendance statistics: $e';
    }
  }

  // Get attendance statistics for a class
  Future<Map<String, dynamic>> getAttendanceStatsForClass(
    String classId,
  ) async {
    try {
      //print('Fetching attendance statistics for class: $classId');

      // Use the server-side function (RPC) for better performance
      final response = await supabase.rpc(
        'get_class_attendance_stats',
        params: {'p_class_id': classId},
      );

      // The RPC returns a list with a single object directly mapping to our keys
      // or similar keys. We need to map them to the keys expected by the app.
      // properties: total_sessions, present_count, absent_count, late_count, excused_count, average_attendance

      if (response == null || (response is List && response.isEmpty)) {
        return {
          'totalSessions': 0,
          'presentCount': 0,
          'absentCount': 0,
          'lateCount': 0,
          'averageAttendance': 0.0,
        };
      }

      final data = response is List ? response.first : response;

      return {
        'totalSessions': data['total_sessions'] ?? 0,
        'presentCount': data['present_count'] ?? 0,
        'absentCount': data['absent_count'] ?? 0,
        'lateCount': data['late_count'] ?? 0,
        'averageAttendance': (data['average_attendance'] ?? 0.0).toDouble(),
      };
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error getting attendance statistics: $e');
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
      //print(
      // 'Fetching attendance statistics for date range: $startDate to $endDate');
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
      final double averageAttendance = totalRecords > 0
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
      //print('Error getting attendance statistics for date range: $e');
      throw 'Failed to get attendance statistics: $e';
    }
  }

  // Get attendance statistics for a student
  Future<Map<String, dynamic>> getAttendanceStatsForStudent({
    required String classId,
    required String studentId,
  }) async {
    try {
      //print(
      // 'Fetching attendance statistics for student: $studentId in class: $classId');
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
      final double attendancePercentage = totalSessions > 0
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
      //print('Error getting student attendance statistics: $e');
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
      //print(
      // 'Fetching attendance statistics for student: $studentId for date range: $startDate to $endDate');
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
      final double attendancePercentage = totalSessions > 0
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
      //print('Error getting student attendance statistics for date range: $e');
      throw 'Failed to get student attendance statistics: $e';
    }
  }

  // Get student attendance history (Optimized for Scaling)
  Future<List<Map<String, dynamic>>> getStudentAttendanceHistory({
    required String classId,
    required String studentId,
  }) async {
    try {
      // 1. Get all sessions for the class
      final sessions = await getAttendanceSessions(classId);
      if (sessions.isEmpty) return [];

      // 2. Fetch all attendance records for this student in these sessions in ONE query
      final sessionIds = sessions.map((s) => s.id).toList();
      final recordsResponse = await supabase
          .from('attendance_records')
          .select()
          .eq('student_id', studentId)
          .inFilter('session_id', sessionIds);

      final List<Map<String, dynamic>> records = recordsResponse;

      // 3. Create a map for fast record lookup
      final recordsBySession = {
        for (var r in records) r['session_id']: r
      };

      // 4. Build history by matching sessions to records in-memory
      final history = <Map<String, dynamic>>[];
      for (var session in sessions) {
        final record = recordsBySession[session.id];
        if (record != null) {
          history.add({
            'session': session,
            'status': record['status'],
            'remarks': record['remarks'],
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
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw 'Failed to get student attendance history: $e';
    }
  }

  // Get attendance status for a specific session
  Future<String> getAttendanceStatusForSession({
    required String sessionId,
    required String studentId,
  }) async {
    try {
      final response = await supabase
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

  // the AttendanceService class
  // Get attendance records for a specific list of students in a session
  Future<List<AttendanceRecordModel>> getAttendanceRecordsForStudentsInSession(
    String sessionId,
    List<String> studentIds,
  ) async {
    try {
      if (studentIds.isEmpty) return [];
      
      final response = await supabase
          .from('attendance_records')
          .select()
          .eq('session_id', sessionId)
          .inFilter('student_id', studentIds);

      return (response as List).map<AttendanceRecordModel>((json) {
        return AttendanceRecordModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw 'Failed to get attendance records: $e';
    }
  }

  // Get attendance statistics for multiple students in a class and date range (Batched)
  Future<Map<String, Map<String, dynamic>>> getAttendanceStatsForStudentsInDateRange({
    required String classId,
    required List<String> studentIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (studentIds.isEmpty) return {};

      // Get sessions in date range
      final sessions = await getAttendanceSessionsForDateRange(
        classId: classId,
        startDate: startDate,
        endDate: endDate,
      );

      if (sessions.isEmpty) {
        return {
          for (var id in studentIds)
            id: {
              'totalSessions': 0,
              'presentCount': 0,
              'absentCount': 0,
              'lateCount': 0,
              'attendancePercentage': 0.0,
            }
        };
      }

      final sessionIds = sessions.map((s) => s.id).toList();
      
      // Fetch all records for these students in these sessions
      final response = await supabase
          .from('attendance_records')
          .select('student_id, status')
          .inFilter('session_id', sessionIds)
          .inFilter('student_id', studentIds);

      final results = <String, Map<String, dynamic>>{};
      for (var id in studentIds) {
        results[id] = {
          'totalSessions': sessions.length,
          'presentCount': 0,
          'absentCount': 0, // We'll calculate this as total - (present + late + excused)
          'lateCount': 0,
          'attendancePercentage': 0.0,
        };
      }

      // Group records by student
      final recordsByStudent = <String, List<String>>{};
      for (var record in response) {
        final sId = record['student_id'] as String;
        final status = record['status'] as String;
        recordsByStudent.putIfAbsent(sId, () => []).add(status);
      }

      for (var sId in studentIds) {
        final statuses = recordsByStudent[sId] ?? [];
        int p = 0;
        int l = 0;
        for (var status in statuses) {
          if (status == 'present') {
            p++;
          } else if (status == 'late') {
            l++;
          }
        }
        
        final totalSessionsForStudent = sessions.length;
        final absent = totalSessionsForStudent - statuses.length; // Students with no record are absent by default
        
        results[sId]!['presentCount'] = p;
        results[sId]!['lateCount'] = l;
        results[sId]!['absentCount'] = absent + (statuses.length - p - l);
        results[sId]!['attendancePercentage'] = totalSessionsForStudent > 0
            ? ((p + (l * 0.5)) / totalSessionsForStudent) * 100
            : 0.0;
      }

      return results;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw 'Failed to get batched student attendance statistics: $e';
    }
  }

   Future<void> submitBulkAttendance({
     required String sessionId,
     required List<Map<String, dynamic>> records,
   }) async {
     try {
       if (records.isEmpty) return;
       debugPrint('Submitting ${records.length} attendance records for session $sessionId');
 
       // Check connectivity
       final connectivity = Get.find<ConnectivityService>();
       if (!connectivity.isOnline.value) {
         debugPrint('Offline: Queuing ${records.length} records locally');
         final localDb = LocalDbService();
         for (var record in records) {
           await localDb.queueAttendance({
             'session_id': sessionId,
             'student_id': record['student_id'],
             'status': record['status'],
             'remarks': record['remarks'],
           });
         }
         return;
       }

      final now = DateTime.now().toIso8601String();
      final List<Map<String, dynamic>> upsertData = records.map((record) {
        return {
          'session_id': sessionId,
          'student_id': record['student_id'],
          'status': (record['status'] as String).toLowerCase(),
          'remarks': record['remarks'],
          'updated_at': now,
          // Since we're upserting, we don't strictly need created_at if already exists,
          // but if it's new, we'll want it.
        };
      }).toList();

      // Using upsert with student_id and session_id as the unique constraint
      // Assuming session_id and student_id form a unique constraint on attendance_records
      await supabase.from('attendance_records').upsert(
        upsertData,
        onConflict: 'session_id, student_id',
      );

      debugPrint('Bulk submission successful');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw 'Failed to submit bulk attendance: $e';
    }
  }

  // Fetches all attendance sessions for a specific teacher with pagination
  Future<List<AttendanceSessionModel>> getSessionsForTeacher({
    required String teacherId,
    int limit = defaultSessionFetchLimit,
    int offset = 0,
  }) async {
    try {
      debugPrint('Fetching sessions for teacher: $teacherId with limit: $limit, offset: $offset');
      
      // Use the attendance_session_details view which already has all the joined data
      // Filter by teacher_id/created_by
      final response = await supabase
          .from('attendance_session_details')
          .select()
          .eq('created_by', teacherId)
          .range(offset, offset + limit - 1)
          .order('date', ascending: false);

      return (response as List)
          .map((data) => AttendanceSessionModel.fromJson(data))
          .toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error fetching teacher attendance sessions: $e');
      throw 'Failed to load attendance sessions';
    }
  }

  // Fetches all attendance sessions from the database
  Future<List<AttendanceSessionModel>> getAllAttendanceSessions() async {
    try {
      // Use the attendance_session_details view which already has all the joined data
      // No filtering by teacher_id to get ALL sessions
      final response = await supabase
          .from('attendance_session_details')
          .select()
          .order('date', ascending: false);

      //print('Attendance sessions response: ${response.length} sessions loaded');

      return (response as List)
          .map((data) => AttendanceSessionModel.fromJson(data))
          .toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error fetching all attendance sessions: $e');
      throw 'Failed to load attendance sessions';
    }
  }

  // Fetches classes created by the current teacher
  Future<List<ClassModel>> getTeacherClasses() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final response =
          await supabase.from('classes').select('*').eq('teacher_id', user.id);

      return (response as List)
          .map((data) => ClassModel.fromJson(data))
          .toList();
    } catch (e) {
      //print('Error fetching teacher classes: $e');
      throw 'Failed to load classes';
    }
  }

  // these methods to the AttendanceService class

  // Fetches a specific attendance session by its ID
  Future<AttendanceSessionModel> getSessionById(String sessionId) async {
    try {
      //print('Fetching attendance session with ID: $sessionId');
      final response = await supabase
          .from('attendance_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      return AttendanceSessionModel.fromJson(response);
    } catch (e) {
      //print('Error getting session by ID: $e');
      throw 'Failed to get session details: $e';
    }
  }

  // Updates an attendance record with new status
  Future<void> updateAttendanceRecord(String recordId, bool isPresent) async {
    try {
      //print('Updating attendance record: $recordId to isPresent=$isPresent');

      // Convert boolean to string status
      final status = isPresent ? 'present' : 'absent';

      await supabase.from('attendance_records').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', recordId);

      //print('Attendance record updated successfully');
    } catch (e) {
      //print('Error updating attendance record: $e');
      throw 'Failed to update attendance record: $e';
    }
  }

  // Gets detailed attendance records including student information
  Future<List<Map<String, dynamic>>> getDetailedAttendanceRecords(
      String sessionId) async {
    try {
      //print('Fetching detailed attendance records for session: $sessionId');

      // Join attendance_records with students table to get student names
      final response = await supabase.from('attendance_records').select('''
          id,
          student_id,
          status,
          remarks,
          students:student_id (
            first_name,
            last_name,
            roll_number
          )
        ''').eq('session_id', sessionId);

      // Transform the response into a more usable format
      return (response as List).map<Map<String, dynamic>>((record) {
        final student = record['students'] as Map<String, dynamic>;
        final studentName =
            '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}'
                .trim();

        return {
          'id': record['id'],
          'studentId': record['student_id'],
          'studentName':
              studentName.isNotEmpty ? studentName : 'Unknown Student',
          'rollNumber': student['roll_number'],
          'isPresent': record['status'] == 'present',
          'status': record['status'],
          'remarks': record['remarks'],
        };
      }).toList();
    } catch (e) {
      //print('Error getting detailed attendance records: $e');
      throw 'Failed to get attendance records: $e';
    }
  }

  // Gets attendance statistics for a specific session
  Future<Map<String, dynamic>> getSessionAttendanceStats(
      String sessionId) async {
    try {
      //print('Calculating attendance statistics for session: $sessionId');

      final records = await supabase
          .from('attendance_records')
          .select('status')
          .eq('session_id', sessionId);

      int presentCount = 0;
      int absentCount = 0;
      int lateCount = 0;

      for (var record in records) {
        final status = record['status'] as String;
        if (status == 'present') {
          presentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'late') {
          lateCount++;
        }
      }

      final totalCount = records.length;

      return {
        'total': totalCount,
        'present': presentCount,
        'absent': absentCount,
        'late': lateCount,
        'attendanceRate': totalCount > 0
            ? ((presentCount + (lateCount * 0.5)) / totalCount) * 100
            : 0.0,
      };
    } catch (e) {
      //print('Error calculating session attendance statistics: $e');
      throw 'Failed to get attendance statistics: $e';
    }
  }

  // Exports attendance data for a session (returns data that can be used for CSV/PDF)
  Future<List<Map<String, dynamic>>> exportSessionAttendanceData(
      String sessionId) async {
    try {
      //print('Exporting attendance data for session: $sessionId');

      // Get session details
      final session = await getSessionById(sessionId);

      // Get detailed attendance records
      final records = await getDetailedAttendanceRecords(sessionId);

      // Format data for export
      final exportData = records.map((record) {
        return {
          'Date': session.date.toString().split(' ')[0],
          'Subject': session.subjectName ?? 'Unknown Subject',
          'Student ID': record['studentId'],
          'Student Name': record['studentName'],
          'Roll Number': record['rollNumber'] ?? 'N/A',
          'Status': record['status']?.toUpperCase() ?? 'NOT RECORDED',
          'Remarks': record['remarks'] ?? '',
        };
      }).toList();

      return exportData;
    } catch (e) {
      //print('Error exporting attendance data: $e');
      throw 'Failed to export attendance data: $e';
    }
  }

  // Checks if a session is currently active
  bool isSessionActive(AttendanceSessionModel session) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate =
        DateTime(session.date.year, session.date.month, session.date.day);

    // If not today, it's not active
    if (sessionDate != today) return false;

    // Check if session is currently active
    if (session.startTime == null || session.endTime == null) return false;

    try {
      // Parse time in format "06 AM" or "07 PM"
      int startHour = 0;
      int startMinute = 0;
      int endHour = 0;
      int endMinute = 0;

      // Parse start time
      final startTimeParts = session.startTime!.split(' ');
      if (startTimeParts.length == 2) {
        final timePart = startTimeParts[0];
        final amPm = startTimeParts[1].toUpperCase();

        if (timePart.contains(':')) {
          final parts = timePart.split(':');
          startHour = int.parse(parts[0]);
          startMinute = int.parse(parts[1]);
        } else {
          startHour = int.parse(timePart);
          startMinute = 0;
        }

        // Convert to 24-hour format
        if (amPm == 'PM' && startHour < 12) {
          startHour += 12;
        } else if (amPm == 'AM' && startHour == 12) {
          startHour = 0;
        }
      }

      // Parse end time
      final endTimeParts = session.endTime!.split(' ');
      if (endTimeParts.length == 2) {
        final timePart = endTimeParts[0];
        final amPm = endTimeParts[1].toUpperCase();

        if (timePart.contains(':')) {
          final parts = timePart.split(':');
          endHour = int.parse(parts[0]);
          endMinute = int.parse(parts[1]);
        } else {
          endHour = int.parse(timePart);
          endMinute = 0;
        }

        // Convert to 24-hour format
        if (amPm == 'PM' && endHour < 12) {
          endHour += 12;
        } else if (amPm == 'AM' && endHour == 12) {
          endHour = 0;
        }
      }

      final sessionStart =
          DateTime(today.year, today.month, today.day, startHour, startMinute);
      final sessionEnd =
          DateTime(today.year, today.month, today.day, endHour, endMinute);

      return now.isAfter(sessionStart) && now.isBefore(sessionEnd);
    } catch (e) {
      //print('Error parsing session times: $e');
      return false;
    }
  }

  // Fetches a teacher's name by their user ID
  Future<String> getTeacherName(String userId) async {
    try {
      //print('Fetching teacher name for user ID: $userId');

      // Query the profiles table to get the user's name
      final response = await supabase
          .from('profiles')
          .select('first_name, last_name')
          .eq('id', userId)
          .single();

      final firstName = response['first_name'] as String? ?? '';
      final lastName = response['last_name'] as String? ?? '';

      final fullName = '$firstName $lastName'.trim();
      return fullName.isNotEmpty ? fullName : 'Unknown Teacher';
    } catch (e) {
      //print('Error fetching teacher name: $e');
      return 'Unknown Teacher';
    }
  }
}
