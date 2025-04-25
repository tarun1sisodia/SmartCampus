import 'package:attedance__/models/attendance_record_model.dart';
import 'package:attedance__/models/attendance_session_model.dart';
import 'package:attedance__/models/class_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final supabase = Supabase.instance.client;

  // Get attendance sessions for a class
  Future<List<AttendanceSessionModel>> getAttendanceSessions(
    String classId,
  ) async {
    try {
      //print('Fetching attendance sessions for class: $classId');
      final response = await supabase
          .from('attendance_sessions')
          .select()
          .eq('class_id', classId)
          .order('date', ascending: false);

      return response.map<AttendanceSessionModel>((json) {
        return AttendanceSessionModel.fromJson(json);
      }).toList();
    } catch (e) {
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
      //print(
          // 'Fetching attendance sessions for date range: $startDate to $endDate');
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
      //print('Error getting attendance sessions for date range: $e');
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
      //print('Creating new attendance session for class: $classId');
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

      final response = await supabase
          .from('attendance_sessions')
          .insert(data)
          .select()
          .single();

      return AttendanceSessionModel.fromJson(response);
    } catch (e) {
      //print('Error creating attendance session: $e');
      throw 'Failed to create attendance session: $e';
    }
  }

  // Existing methods and properties

  /// Deletes an attendance session by its ID.
  ///
  /// This method interacts with the backend to delete the session
  /// with the specified [sessionId]. Throws an exception if the
  /// deletion fails.
  Future<void> deleteSession(String sessionId) async {
    try {
      //print('Deleting attendance session: $sessionId');
      // First delete all attendance records for this session
      await supabase
          .from('attendance_records')
          .delete()
          .eq('session_id', sessionId);

      // Then delete the session
      await supabase.from('attendance_sessions').delete().eq('id', sessionId);
    } catch (e) {
      //print('Error deleting session: $e');
      throw 'Failed to delete session: $e';
    }
  }

  // Get attendance records for a session
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
    String sessionId,
  ) async {
    try {
      //print('Fetching attendance records for session: $sessionId');
      final response = await supabase
          .from('attendance_records')
          .select()
          .eq('session_id', sessionId);

      return response.map<AttendanceRecordModel>((json) {
        return AttendanceRecordModel.fromJson(json);
      }).toList();
    } catch (e) {
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
      //print('Error submitting attendance: $e');
      throw 'Failed to submit attendance: $e';
    }
  }

  /// Closes an attendance session by updating its status
  Future<void> closeAttendanceSession(String sessionId) async {
    try {
      //print('Closing attendance session: $sessionId');

      // Update the session with a closed status
      await supabase.from('attendance_sessions').update({
        'status': 'closed',
        'closed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);

      //print('Session closed successfully');
    } catch (e) {
      //print('Error closing attendance session: $e');
      throw 'Failed to close attendance session: $e';
    }
  }

  // Get attendance statistics for a class
  Future<Map<String, dynamic>> getAttendanceStatsForClass(
    String classId,
  ) async {
    try {
      //print('Fetching attendance statistics for class: $classId');
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
        final response = await supabase
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

  //for bulk attendance submission
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

  /// Fetches all attendance sessions from the database
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
    } catch (e) {
      //print('Error fetching all attendance sessions: $e');
      throw 'Failed to load attendance sessions';
    }
  }

  /// Fetches classes created by the current teacher
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

  // Add these methods to the AttendanceService class

  /// Fetches a specific attendance session by its ID
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

  /// Updates an attendance record with new status
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

  /// Gets detailed attendance records including student information
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

  /// Gets attendance statistics for a specific session
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

  /// Exports attendance data for a session (returns data that can be used for CSV/PDF)
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

  /// Checks if a session is currently active
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

  /// Fetches a teacher's name by their user ID
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
