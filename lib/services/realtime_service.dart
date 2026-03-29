import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService extends GetxService {
  final supabase = Supabase.instance.client;
  final List<StreamSubscription> _subscriptions = [];

  // Stream controllers for different data types
  final _classesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _studentsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _attendanceController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _attendanceRecordsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _subjectsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _coursesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Connection status
  final isConnected = true.obs;
  final lastError = Rxn<String>();
  final connectionAttempts = 0.obs;
  final maxRetryAttempts = 5;

  // Getters for streams
  Stream<List<Map<String, dynamic>>> get classesStream =>
      _classesController.stream;
  Stream<List<Map<String, dynamic>>> get studentsStream =>
      _studentsController.stream;
  Stream<List<Map<String, dynamic>>> get attendanceStream =>
      _attendanceController.stream;
  Stream<List<Map<String, dynamic>>> get attendanceSessionsStream =>
      _attendanceController.stream; // Alias for backward compatibility
  Stream<List<Map<String, dynamic>>> get attendanceRecordsStream =>
      _attendanceRecordsController.stream;
  Stream<List<Map<String, dynamic>>> get subjectsStream =>
      _subjectsController.stream;
  Stream<List<Map<String, dynamic>>> get coursesStream =>
      _coursesController.stream;

  // Observable data
  final classes = <Map<String, dynamic>>[].obs;
  final students = <Map<String, dynamic>>[].obs;
  final attendanceRecords = <Map<String, dynamic>>[].obs;
  final attendanceSessionRecords = <Map<String, dynamic>>[].obs; // For attendance_records table
  final subjects = <Map<String, dynamic>>[].obs;
  final courses = <Map<String, dynamic>>[].obs;

  // Retry timer
  Timer? _retryTimer;

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('RealtimeService initializing...');
    await initializeRealtimeSubscriptions();
  }

  @override
  void onClose() {
    debugPrint('RealtimeService closing...');

    // Cancel retry timer
    _retryTimer?.cancel();

    // Cancel all subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }

    // Close stream controllers
    _classesController.close();
    _studentsController.close();
    _attendanceController.close();
    _attendanceRecordsController.close();
    _subjectsController.close();
    _coursesController.close();

    super.onClose();
  }

  Future<void> initializeRealtimeSubscriptions() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        debugPrint('No user authenticated, skipping real-time subscriptions');
        return;
      }

      debugPrint('Initializing real-time subscriptions for user: ${currentUser.id}');

      // Clear existing subscriptions
      await _clearSubscriptions();

      // Subscribe to classes changes
      final classesSubscription =
          supabase.from('classes').stream(primaryKey: ['id']).listen(
        (data) {
          debugPrint('Classes real-time update: ${data.length} items');
          classes.assignAll(data);
          _classesController.add(data);
          _updateConnectionStatus(true);
        },
        onError: (error) {
          debugPrint('Error in classes stream: $error');
          _handleStreamError('classes', error);
        },
      );

      // Subscribe to students changes (class_students table)
      final studentsSubscription =
          supabase.from('class_students').stream(primaryKey: ['id']).listen(
        (data) {
          debugPrint('Students real-time update: ${data.length} items');
          students.assignAll(data);
          _studentsController.add(data);
          _updateConnectionStatus(true);
        },
        onError: (error) {
          debugPrint('Error in students stream: $error');
          _handleStreamError('students', error);
        },
      );

      // Subscribe to attendance sessions changes
      final attendanceSessionsSubscription = supabase
          .from('attendance_sessions')
          .stream(primaryKey: ['id']).listen(
        (data) {
          debugPrint('Attendance sessions real-time update: ${data.length} items');
          attendanceSessionRecords.assignAll(data);
          _attendanceController.add(data);
          _updateConnectionStatus(true);
        },
        onError: (error) {
          debugPrint('Error in attendance sessions stream: $error');
          _handleStreamError('attendance_sessions', error);
        },
      );

      // Subscribe to attendance records changes
      final attendanceRecordsSubscription =
          supabase.from('attendance_records').stream(primaryKey: ['id']).listen(
        (data) {
          debugPrint('Attendance records real-time update: ${data.length} items');
          attendanceRecords.assignAll(data);
          _attendanceRecordsController.add(data);
          _updateConnectionStatus(true);
        },
        onError: (error) {
          debugPrint('Error in attendance records stream: $error');
          _handleStreamError('attendance_records', error);
        },
      );

      // Subscribe to subjects changes
      final subjectsSubscription =
          supabase.from('subjects').stream(primaryKey: ['id']).listen(
        (data) {
          debugPrint('Subjects real-time update: ${data.length} items');
          subjects.assignAll(data);
          _subjectsController.add(data);
          _updateConnectionStatus(true);
        },
        onError: (error) {
          debugPrint('Error in subjects stream: $error');
          _handleStreamError('subjects', error);
        },
      );

      // Subscribe to courses changes
      final coursesSubscription =
          supabase.from('courses').stream(primaryKey: ['id']).listen(
        (data) {
          debugPrint('Courses real-time update: ${data.length} items');
          courses.assignAll(data);
          _coursesController.add(data);
          _updateConnectionStatus(true);
        },
        onError: (error) {
          debugPrint('Error in courses stream: $error');
          _handleStreamError('courses', error);
        },
      );

      // Add all subscriptions to the list for cleanup
      _subscriptions.addAll([
        classesSubscription,
        studentsSubscription,
        attendanceSessionsSubscription,
        attendanceRecordsSubscription,
        subjectsSubscription,
        coursesSubscription,
      ]);

      // Reset connection attempts and update status
      connectionAttempts.value = 0;
      _updateConnectionStatus(true);
      lastError.value = null;

      debugPrint('Real-time subscriptions initialized successfully');
    } catch (e) {
      debugPrint('Error initializing real-time subscriptions: $e');
      _updateConnectionStatus(false);
      lastError.value = e.toString();
      _scheduleRetry();
    }
  }

  // Handle stream errors
  void _handleStreamError(String streamName, dynamic error) {
    debugPrint('Stream error in $streamName: $error');
    _updateConnectionStatus(false);
    lastError.value = 'Error in $streamName: $error';
    _scheduleRetry();
  }

  // Update connection status
  void _updateConnectionStatus(bool connected) {
    isConnected.value = connected;
    if (connected) {
      connectionAttempts.value = 0;
      _retryTimer?.cancel();
    }
  }

  // Schedule retry attempt
  void _scheduleRetry() {
    if (connectionAttempts.value >= maxRetryAttempts) {
      debugPrint('Max retry attempts reached. Stopping retries.');
      return;
    }

    _retryTimer?.cancel();

    final retryDelay = Duration(seconds: (connectionAttempts.value + 1) * 2);
    debugPrint('Scheduling retry in ${retryDelay.inSeconds} seconds...');

    _retryTimer = Timer(retryDelay, () {
      connectionAttempts.value++;
      debugPrint('Retry attempt ${connectionAttempts.value}/$maxRetryAttempts');
      initializeRealtimeSubscriptions();
    });
  }

  // Clear existing subscriptions
  Future<void> _clearSubscriptions() async {
    for (var subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  // Method to manually refresh all data
  Future<void> refreshAllData() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        debugPrint('No user authenticated for data refresh');
        return;
      }

      debugPrint('Refreshing all data...');

      // Fetch fresh data for all tables
      final classesData = await supabase
          .from('classes')
          .select('*, subjects(*), courses(*)')
          .eq('teacher_id', currentUser.id);

      final studentsData =
          await supabase.from('class_students').select('*, students(*)');

      final attendanceData =
          await supabase.from('attendance_sessions').select();

      final attendanceRecordsData =
          await supabase.from('attendance_records').select();

      final subjectsData = await supabase.from('subjects').select();

      final coursesData = await supabase.from('courses').select();

      // Update observable data
      classes.assignAll(classesData);
      students.assignAll(studentsData);
      attendanceRecords.assignAll(attendanceData);
      attendanceSessionRecords.assignAll(attendanceRecordsData);
      subjects.assignAll(subjectsData);
      courses.assignAll(coursesData);

      // Emit to streams
      _classesController.add(classesData);
      _studentsController.add(studentsData);
      _attendanceController.add(attendanceData);
      _attendanceRecordsController.add(attendanceRecordsData);
      _subjectsController.add(subjectsData);
      _coursesController.add(coursesData);

      debugPrint('All data refreshed successfully');
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      lastError.value = 'Failed to refresh data: $e';
    }
  }

  // Method to force reconnect
  Future<void> forceReconnect() async {
    debugPrint('Force reconnecting real-time service...');
    connectionAttempts.value = 0;
    _retryTimer?.cancel();
    await initializeRealtimeSubscriptions();
  }

  // Method to get real-time stats
  Map<String, dynamic> getRealtimeStats() {
    return {
      'isConnected': isConnected.value,
      'totalClasses': classes.length,
      'totalStudents': students.length,
      'totalSessions': attendanceRecords.length,
      'totalAttendanceRecords': attendanceSessionRecords.length,
      'totalSubjects': subjects.length,
      'totalCourses': courses.length,
      'connectionAttempts': connectionAttempts.value,
      'lastError': lastError.value,
    };
  }

  // Method to get connection status string
  String getConnectionStatusString() {
    if (isConnected.value) {
      return 'Connected';
    } else if (connectionAttempts.value > 0) {
      return 'Reconnecting... (${connectionAttempts.value}/$maxRetryAttempts)';
    } else {
      return 'Disconnected';
    }
  }

  // Method to check if service is healthy
  bool get isHealthy => isConnected.value && lastError.value == null;

  // Helper methods to get specific data streams with filtering

  // Get attendance sessions for a specific class
  Stream<List<Map<String, dynamic>>> getAttendanceSessionsForClass(String classId) {
    return attendanceStream.map((sessions) =>
        sessions.where((session) => session['class_id'] == classId).toList());
  }

  // Get attendance records for a specific session
  Stream<List<Map<String, dynamic>>> getAttendanceRecordsForSession(String sessionId) {
    return attendanceRecordsStream.map((records) =>
        records.where((record) => record['session_id'] == sessionId).toList());
  }

  // Get attendance records for a specific student
  Stream<List<Map<String, dynamic>>> getAttendanceRecordsForStudent(String studentId) {
    return attendanceRecordsStream.map((records) =>
        records.where((record) => record['student_id'] == studentId).toList());
  }

  // Get classes for current teacher
  Stream<List<Map<String, dynamic>>> getClassesForTeacher() {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    
    return classesStream.map((classes) =>
        classes.where((classData) => classData['teacher_id'] == currentUser.id).toList());
  }

  // Get students for a specific class
  Stream<List<Map<String, dynamic>>> getStudentsForClass(String classId) {
    return studentsStream.map((students) =>
        students.where((student) => student['class_id'] == classId).toList());
  }

  // Method to subscribe to specific table changes with custom filters
  StreamSubscription<List<Map<String, dynamic>>>? subscribeToTable({
    required String tableName,
    required List<String> primaryKey,
    required Function(List<Map<String, dynamic>>) onData,
    Function(dynamic)? onError,
    Map<String, dynamic>? filters,
  }) {
    try {
      dynamic query = supabase.from(tableName).stream(primaryKey: primaryKey);
      
      // Apply filters if provided
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      return query.listen(
        onData,
        onError: onError ?? (error) => _handleStreamError(tableName, error),
      );
    } catch (e) {
      debugPrint('Error subscribing to table $tableName: $e');
      return null;
    }
  }

  // Method to get attendance statistics in real-time
  Stream<Map<String, int>> getAttendanceStatsStream(String classId) {
    return attendanceRecordsStream.map((records) {
      final classRecords = records.where((record) {
        // You might need to join with sessions to filter by class_id
        // For now, this is a simplified version
        return true; // Implement proper filtering based on your needs
      }).toList();

      int presentCount = 0;
      int absentCount = 0;
      int lateCount = 0;
      int excusedCount = 0;

      for (var record in classRecords) {
        switch (record['status']) {
                    case 'present':
            presentCount++;
            break;
          case 'absent':
            absentCount++;
            break;
          case 'late':
            lateCount++;
            break;
          case 'excused':
            excusedCount++;
            break;
        }
      }

      return {
        'present': presentCount,
        'absent': absentCount,
        'late': lateCount,
        'excused': excusedCount,
        'total': classRecords.length,
      };
    });
  }

  // Method to get real-time attendance data for a specific date range
  Stream<List<Map<String, dynamic>>> getAttendanceForDateRange({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return attendanceStream.map((sessions) {
      return sessions.where((session) {
        if (session['class_id'] != classId) return false;
        
        try {
          final sessionDate = DateTime.parse(session['date']);
          return sessionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 sessionDate.isBefore(endDate.add(const Duration(days: 1)));
        } catch (e) {
          debugPrint('Error parsing session date: $e');
          return false;
        }
      }).toList();
    });
  }

  // Method to get combined attendance data (sessions + records)
  Stream<List<Map<String, dynamic>>> getCombinedAttendanceData(String classId) {
    return StreamZip.zip([
      getAttendanceSessionsForClass(classId),
      attendanceRecordsStream,
    ]).map((data) {
      final sessions = data[0] as List<Map<String, dynamic>>;
      final records = data[1] as List<Map<String, dynamic>>;
      
      return sessions.map((session) {
        final sessionRecords = records
            .where((record) => record['session_id'] == session['id'])
            .toList();
        
        return {
          ...session,
          'attendance_records': sessionRecords,
          'total_marked': sessionRecords.length,
          'present_count': sessionRecords.where((r) => r['status'] == 'present').length,
          'absent_count': sessionRecords.where((r) => r['status'] == 'absent').length,
          'late_count': sessionRecords.where((r) => r['status'] == 'late').length,
          'excused_count': sessionRecords.where((r) => r['status'] == 'excused').length,
        };
      }).toList();
    });
  }

  // Method to get student attendance summary in real-time
  Stream<Map<String, Map<String, dynamic>>> getStudentAttendanceSummary(String classId) {
    return StreamZip.zip([
      getStudentsForClass(classId),
      attendanceRecordsStream,
      getAttendanceSessionsForClass(classId),
    ]).map((data) {
      final students = data[0] as List<Map<String, dynamic>>;
      final records = data[1] as List<Map<String, dynamic>>;
      final sessions = data[2] as List<Map<String, dynamic>>;
      
      final sessionIds = sessions.map((s) => s['id']).toSet();
      final totalSessions = sessions.length;
      
      final studentSummary = <String, Map<String, dynamic>>{};
      
      for (var student in students) {
        final studentId = student['student_id'];
        final studentRecords = records
            .where((record) => 
                record['student_id'] == studentId && 
                sessionIds.contains(record['session_id']))
            .toList();
        
        int presentCount = 0;
        int absentCount = 0;
        int lateCount = 0;
        int excusedCount = 0;
        
        for (var record in studentRecords) {
          switch (record['status']) {
            case 'present':
              presentCount++;
              break;
            case 'absent':
              absentCount++;
              break;
            case 'late':
              lateCount++;
              break;
            case 'excused':
              excusedCount++;
              break;
          }
        }
        
        final attendancePercentage = totalSessions > 0 
            ? ((presentCount + (lateCount * 0.5)) / totalSessions) * 100
            : 0.0;
        
        studentSummary[studentId] = {
          'student_data': student,
          'total_sessions': totalSessions,
          'present_count': presentCount,
          'absent_count': absentCount,
          'late_count': lateCount,
          'excused_count': excusedCount,
          'attendance_percentage': attendancePercentage,
          'total_marked': studentRecords.length,
        };
      }
      
      return studentSummary;
    });
  }

  // Method to get real-time notifications for attendance changes
  Stream<Map<String, dynamic>> getAttendanceNotifications() {
    return attendanceRecordsStream.map((records) {
      // Get the latest record (assuming records are ordered by created_at)
      if (records.isEmpty) return {};
      
      final latestRecord = records.last;
      return {
        'type': 'attendance_marked',
        'student_id': latestRecord['student_id'],
        'session_id': latestRecord['session_id'],
        'status': latestRecord['status'],
        'timestamp': latestRecord['created_at'] ?? latestRecord['updated_at'],
      };
    });
  }

  // Method to monitor connection health
  Stream<Map<String, dynamic>> getConnectionHealthStream() {
    return Stream.periodic(const Duration(seconds: 30), (count) {
      return {
        'is_connected': isConnected.value,
        'connection_attempts': connectionAttempts.value,
        'last_error': lastError.value,
        'uptime_seconds': count * 30,
        'total_subscriptions': _subscriptions.length,
        'health_status': isHealthy ? 'healthy' : 'unhealthy',
      };
    });
  }

  // Method to get data freshness indicators
  Map<String, DateTime> getDataFreshness() {
    final now = DateTime.now();
    return {
      'classes': now,
      'students': now,
      'attendance_sessions': now,
      'attendance_records': now,
      'subjects': now,
      'courses': now,
    };
  }

  // Method to validate data integrity
  Future<Map<String, bool>> validateDataIntegrity() async {
    try {
      final results = <String, bool>{};
      
      // Check if we have data in all streams
      results['classes_available'] = classes.isNotEmpty;
      results['students_available'] = students.isNotEmpty;
      results['sessions_available'] = attendanceRecords.isNotEmpty;
      results['records_available'] = attendanceSessionRecords.isNotEmpty;
      results['subjects_available'] = subjects.isNotEmpty;
      results['courses_available'] = courses.isNotEmpty;
      
      // Check connection status
      results['connection_healthy'] = isConnected.value;
      results['no_recent_errors'] = lastError.value == null;
      
      return results;
    } catch (e) {
      debugPrint('Error validating data integrity: $e');
      return {'validation_failed': false};
    }
  }

  // Method to get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'active_subscriptions': _subscriptions.length,
      'connection_attempts': connectionAttempts.value,
      'is_connected': isConnected.value,
      'data_counts': {
        'classes': classes.length,
        'students': students.length,
        'attendance_sessions': attendanceRecords.length,
        'attendance_records': attendanceSessionRecords.length,
        'subjects': subjects.length,
        'courses': courses.length,
      },
      'memory_usage': {
        'stream_controllers': 6,
        'subscriptions': _subscriptions.length,
      },
    };
  }

  // Method to cleanup specific subscriptions
  Future<void> cleanupSubscription(String tableName) async {
    try {
      final subscriptionsToRemove = <StreamSubscription>[];
      
      for (var subscription in _subscriptions) {
        // This is a simplified check - you might need to implement
        // a more sophisticated way to identify subscriptions by table name
        subscriptionsToRemove.add(subscription);
      }
      
      for (var subscription in subscriptionsToRemove) {
        await subscription.cancel();
        _subscriptions.remove(subscription);
      }
      
      debugPrint('Cleaned up subscriptions for table: $tableName');
    } catch (e) {
      debugPrint('Error cleaning up subscriptions for $tableName: $e');
    }
  }

  // Method to pause/resume real-time updates
  void pauseRealtimeUpdates() {
    for (var subscription in _subscriptions) {
      subscription.pause();
    }
    debugPrint('Real-time updates paused');
  }

  void resumeRealtimeUpdates() {
    for (var subscription in _subscriptions) {
      subscription.resume();
    }
    debugPrint('Real-time updates resumed');
  }

  // Method to get stream status
  Map<String, bool> getStreamStatus() {
    return {
      'classes_stream_active': !_classesController.isClosed,
      'students_stream_active': !_studentsController.isClosed,
      'attendance_sessions_stream_active': !_attendanceController.isClosed,
      'attendance_records_stream_active': !_attendanceRecordsController.isClosed,
      'subjects_stream_active': !_subjectsController.isClosed,
      'courses_stream_active': !_coursesController.isClosed,
    };
  }
}

// Extension to add StreamZip functionality if not available
extension StreamZip<T> on Stream<T> {
  static Stream<List<dynamic>> zip(List<Stream> streams) {
    late StreamController<List<dynamic>> controller;
    late List<StreamSubscription> subscriptions;
    List<dynamic> currentValues = List.filled(streams.length, null);
    List<bool> hasValue = List.filled(streams.length, false);

    controller = StreamController<List<dynamic>>(
      onListen: () {
        subscriptions = streams.asMap().entries.map((entry) {
          return entry.value.listen((value) {
            currentValues[entry.key] = value;
            hasValue[entry.key] = true;
            
            // Emit only when all streams have emitted at least once
            if (hasValue.every((has) => has)) {
              controller.add(List.from(currentValues));
            }
          });
        }).toList();
      },
      onCancel: () {
        for (var subscription in subscriptions) {
          subscription.cancel();
        }
      },
    );

    return controller.stream;
  }
}

// Helper class for combining multiple streams
class StreamZipHelper {
  static Stream<List<dynamic>> zip(List<Stream> streams) {
    return StreamZip.zip(streams);
  }
}
