import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:async';

import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../models/attendance_session_model.dart';
import '../../../models/class_model.dart';
import '../../../models/student_model.dart';
import '../../../services/attendance_service.dart';
import '../../../services/class_service.dart';
import '../../../services/student_service.dart';
import '../../../services/realtime_service.dart';
import '../screens/student_detail_screen.dart';

class AttendanceReportsController extends GetxController {
  final attendanceService = AttendanceService();
  final classService = ClassService();
  final studentService = StudentService();

  // Get RealtimeService instance
  late final RealtimeService realtimeService;

  // Observables
  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final selectedClassId = ''.obs;
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final sessions = <AttendanceSessionModel>[].obs;
  final students = <StudentModel>[].obs;
  final searchQuery = ''.obs;

  // Statistics
  final averageAttendance = 0.0.obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;
  
  // Pagination for students in report
  final hasMoreStudentsInReport = true.obs;
  final isLoadingMoreReport = false.obs;
  int _reportStudentsOffset = 0;
  static const int _reportPageSize = 25;

  // Map to store attendance stats for each student
  final studentStats = <String, Map<String, dynamic>>{}.obs;

  // Real-time connection status
  final isRealtimeConnected = true.obs;
  final lastUpdated = DateTime.now().obs;

  // Filtered data
  final filteredStudents = <StudentModel>[].obs;

  // Convenience getter for UI
  List<StudentModel> get displayStudents => filteredStudents;

  // Get stats for a specific student
  Map<String, dynamic>? getStudentStats(String studentId) => studentStats[studentId];

  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    debugPrint('AttendanceReportsController initialized');
    _initializeRealtimeService();
    loadClasses();
  }

  @override
  void onClose() {
    debugPrint('AttendanceReportsController disposed');

    // Clean up subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  // Initialize the realtime service
  void _initializeRealtimeService() {
    try {
      realtimeService = Get.find<RealtimeService>();
      debugPrint(
          'Found existing RealtimeService instance in AttendanceReportsController');
    } catch (e) {
      debugPrint(
          'RealtimeService not found, creating new instance in AttendanceReportsController');
      realtimeService = Get.put(RealtimeService());
    }

    _setupRealtimeSubscriptions();
  }

  // Set up real-time subscriptions for UI updates
  void _setupRealtimeSubscriptions() {
    // Subscribe to classes stream for real-time updates
    final classesSubscription = realtimeService.classesStream.listen(
      (data) {
        debugPrint(
            'Real-time classes update in AttendanceReportsController: ${data.length} classes');
        _handleClassesUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in classes stream (AttendanceReportsController): $error');
        isRealtimeConnected.value = false;
      },
    );

    // Subscribe to attendance sessions stream
    final attendanceSessionsSubscription =
        realtimeService.attendanceSessionsStream.listen(
      (data) {
        debugPrint(
            'Real-time attendance sessions update in AttendanceReportsController: ${data.length} sessions');
        _handleAttendanceSessionsUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint(
            'Error in attendance sessions stream (AttendanceReportsController): $error');
      },
    );

    // Subscribe to attendance records stream
    final attendanceRecordsSubscription =
        realtimeService.attendanceRecordsStream.listen(
      (data) {
        debugPrint(
            'Real-time attendance records update in AttendanceReportsController: ${data.length} records');
        _handleAttendanceRecordsUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint(
            'Error in attendance records stream (AttendanceReportsController): $error');
      },
    );

    // Subscribe to students stream
    final studentsSubscription = realtimeService.studentsStream.listen(
      (data) {
        debugPrint(
            'Real-time students update in AttendanceReportsController: ${data.length} students');
        _handleStudentsUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in students stream (AttendanceReportsController): $error');
      },
    );

    // Monitor RealtimeService connection status
    final connectionSubscription = realtimeService.isConnected.listen(
      (isConnected) {
        isRealtimeConnected.value = isConnected;
        if (isConnected) {
          debugPrint('Real-time connection restored in AttendanceReportsController');
          // Refresh data when connection is restored
          loadClasses();
          if (selectedClassId.value.isNotEmpty) {
            loadAttendanceData();
          }
        } else {
          debugPrint('Real-time connection lost in AttendanceReportsController');
        }
      },
    );

    _subscriptions.addAll([
      classesSubscription,
      attendanceSessionsSubscription,
      attendanceRecordsSubscription,
      studentsSubscription,
      connectionSubscription,
    ]);

    isRealtimeConnected.value = realtimeService.isConnected.value;
  }

  // Handle real-time classes updates
  void _handleClassesUpdate(List<Map<String, dynamic>> data) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Filter classes for current teacher and convert to ClassModel
      final teacherClasses = <ClassModel>[];

      for (var classData in data) {
        if (classData['teacher_id'] == currentUser.id) {
          try {
            // Fetch related subject and course data
            final subjectData = await Supabase.instance.client
                .from('subjects')
                .select()
                .eq('id', classData['subject_id'])
                .single();

            final courseData = await Supabase.instance.client
                .from('courses')
                .select()
                .eq('id', classData['course_id'])
                .single();

            final classModel = ClassModel(
              id: classData['id'],
              teacherId: classData['teacher_id'],
              subjectId: classData['subject_id'],
              courseId: classData['course_id'],
              semester: classData['semester'],
              section: classData['section'],
              subjectName: subjectData['name'],
              courseName: courseData['name'],
              createdAt: classData['created_at'] != null
                  ? DateTime.parse(classData['created_at'])
                  : null,
              updatedAt: classData['updated_at'] != null
                  ? DateTime.parse(classData['updated_at'])
                  : null,
            );

            teacherClasses.add(classModel);
          } catch (e) {
            debugPrint(
                'Error fetching related data for class ${classData['id']}: $e');
          }
        }
      }

      // Update classes list
      classes.assignAll(teacherClasses);

      // If currently selected class is no longer available, reset selection
      if (selectedClassId.value.isNotEmpty) {
        final selectedClassExists =
            teacherClasses.any((c) => c.id == selectedClassId.value);
        if (!selectedClassExists) {
          selectedClassId.value = '';
          sessions.clear();
          students.clear();
          studentStats.clear();
          _resetStatistics();
        }
      }

      debugPrint(
          'AttendanceReportsController classes updated via real-time: ${teacherClasses.length} classes');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error handling classes update in AttendanceReportsController: $e');
    }
  }

  // Handle real-time attendance sessions updates
  void _handleAttendanceSessionsUpdate(List<Map<String, dynamic>> data) {
    try {
      if (selectedClassId.value.isEmpty) return;

      // Filter sessions for the selected class and date range
      final classSessions = <AttendanceSessionModel>[];

      for (var sessionData in data) {
        if (sessionData['class_id'] == selectedClassId.value) {
          final sessionDate = DateTime.parse(sessionData['date']);

          // Check if session falls within the selected date range
          if (sessionDate
                  .isAfter(startDate.value.subtract(const Duration(days: 1))) &&
              sessionDate
                  .isBefore(endDate.value.add(const Duration(days: 1)))) {
            classSessions.add(AttendanceSessionModel.fromJson(sessionData));
          }
        }
      }

      // Update sessions list
      sessions.assignAll(classSessions);

      // Recalculate statistics
      _recalculateStatistics();

      debugPrint(
          'AttendanceReportsController sessions updated via real-time: ${classSessions.length} sessions');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint(
          'Error handling attendance sessions update in AttendanceReportsController: $e');
    }
  }

  // Handle real-time attendance records updates
  void _handleAttendanceRecordsUpdate(List<Map<String, dynamic>> data) {
    try {
      if (selectedClassId.value.isEmpty || sessions.isEmpty) return;

      // Get session IDs for the current class
      final sessionIds = sessions.map((s) => s.id).toList();

      // Filter records for current sessions
      final relevantRecords = data
          .where((record) => sessionIds.contains(record['session_id']))
          .toList();

      if (relevantRecords.isNotEmpty) {
        // Recalculate statistics when attendance records change
        _recalculateStatistics();

        // Update individual student stats
        _updateStudentStats();
      }

      debugPrint(
          'AttendanceReportsController attendance records updated via real-time: ${relevantRecords.length} relevant records');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint(
          'Error handling attendance records update in AttendanceReportsController: $e');
    }
  }

  // Handle real-time students updates
  void _handleStudentsUpdate(List<Map<String, dynamic>> data) {
    try {
      if (selectedClassId.value.isEmpty) return;

      // This would require checking class_students relationship
      // For now, we'll reload students data when there are changes
      _loadStudentsForClass();

      debugPrint('AttendanceReportsController students updated via real-time');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint(
          'Error handling students update in AttendanceReportsController: $e');
    }
  }

  Future<void> loadMoreReportStudents() async {
    if (selectedClassId.value.isEmpty ||
        isLoading.value ||
        isLoadingMoreReport.value ||
        !hasMoreStudentsInReport.value) {
      return;
    }

    try {
      isLoadingMoreReport.value = true;

      // Load next batch of students for the class
      final nextStudents = await studentService.getStudentsForClass(
        selectedClassId.value,
        limit: _reportPageSize,
        offset: _reportStudentsOffset,
      );

      if (nextStudents.isEmpty) {
        hasMoreStudentsInReport.value = false;
        return;
      }

      // Fetch batched stats for the next batch of students
      final nextStudentIds = nextStudents.map((s) => s.id).toList();
      final nextBatchStats =
          await attendanceService.getAttendanceStatsForStudentsInDateRange(
        classId: selectedClassId.value,
        studentIds: nextStudentIds,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      students.addAll(nextStudents);
      studentStats.addAll(nextBatchStats);
      _reportStudentsOffset = students.length;
      hasMoreStudentsInReport.value = nextStudents.length == _reportPageSize;

      _filterStudents();
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading more report students: $e');
    } finally {
      isLoadingMoreReport.value = false;
    }
  }

  // Load students for the selected class
  Future<void> _loadStudentsForClass() async {
    if (selectedClassId.value.isEmpty) return;

    try {
      final classStudents = await studentService.getStudentsForClass(
        selectedClassId.value,
      );
      students.assignAll(classStudents);
      _filterStudents();
      _updateStudentStats();
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading students for class: $e');
    }
  }

  // Recalculate overall statistics
  Future<void> _recalculateStatistics() async {
    if (selectedClassId.value.isEmpty || sessions.isEmpty) {
      _resetStatistics();
      return;
    }

    try {
      final stats = await attendanceService.getAttendanceStatsForDateRange(
        classId: selectedClassId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      presentCount.value = stats['presentCount'] ?? 0;
      absentCount.value = stats['absentCount'] ?? 0;
      lateCount.value = stats['lateCount'] ?? 0;
      averageAttendance.value = stats['averageAttendance'] ?? 0.0;
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error recalculating statistics: $e');
      _resetStatistics();
    }
  }

  // Update individual student statistics (Batched)
  Future<void> _updateStudentStats() async {
    if (selectedClassId.value.isEmpty) return;

    try {
      // Use high-performance Edge Function for all stats in one go
      final result = await attendanceService.getAttendanceStatsFromEdge(
        classId: selectedClassId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      // Map global stats
      final int total = result['totalSessions'] ?? 0;
      
      // Calculate overall counts from aggregated student stats
      int p = 0;
      int a = 0;
      int l = 0;
      double avg = 0.0;
      
      final Map<String, Map<String, dynamic>> statsMap = (result['stats'] as Map? ?? {}).map(
        (key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value as Map)),
      );
      
      statsMap.forEach((key, val) {
        p += (val['present'] as num? ?? 0).toInt();
        a += (val['absent'] as num? ?? 0).toInt();
        l += (val['late'] as num? ?? 0).toInt();
      });

      // Update observables
      studentStats.assignAll(statsMap);
      presentCount.value = p;
      absentCount.value = a;
      lateCount.value = l;
      
      if (total > 0) {
        averageAttendance.value = ((p + (l * 0.5)) / (total * statsMap.length.clamp(1, 100000))) * 100;
      } else {
        averageAttendance.value = 0.0;
      }
      
      debugPrint('Stats updated via Edge Function. Total sessions: $total');

    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error updating student stats via Edge: $e');
      // If Edge fails, fall back to basic count or show error
      TSnackBar.showWarning(message: 'Using fast-load mode. Some stats may be pending.');
    }
  }

  // Reset statistics to default values
  void _resetStatistics() {
    presentCount.value = 0;
    absentCount.value = 0;
    lateCount.value = 0;
    averageAttendance.value = 0.0;
    studentStats.clear();
  }

  // Filter students based on search query
  void _filterStudents() {
    if (searchQuery.value.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredStudents.assignAll(
        students
            .where((student) =>
                student.name.toLowerCase().contains(query) ||
                student.rollNumber.toLowerCase().contains(query))
            .toList(),
      );
    }
  }

  // Public method to update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _filterStudents();
  }

  // Load all classes for the current teacher (initial load)
  Future<void> loadClasses() async {
    try {
      debugPrint('Loading classes...');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('User not authenticated');
        TSnackBar.showError(message: 'You must be logged in to view reports');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );
      debugPrint('Classes fetched: ${teacherClasses.length}');
      classes.assignAll(teacherClasses);

      if (classes.isNotEmpty && selectedClassId.isEmpty) {
        selectedClassId.value = classes[0].id;
        debugPrint('Selected class ID: ${selectedClassId.value}');
        await loadAttendanceData();
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading classes: $e');
      TSnackBar.showError(message: 'Failed to load classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
      _reportStudentsOffset = 0;
      hasMoreStudentsInReport.value = true;
    }
  }

  // Load attendance data for the selected class and date range
  Future<void> loadAttendanceData() async {
    try {
      if (selectedClassId.isEmpty) {
        debugPrint('No class selected');
        return;
      }

      debugPrint('Loading attendance data for class: ${selectedClassId.value}');
      isLoading.value = true;
      _reportStudentsOffset = 0;
      hasMoreStudentsInReport.value = true;

      // Load sessions for the date range
      final classSessions =
          await attendanceService.getAttendanceSessionsForDateRange(
        classId: selectedClassId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      debugPrint('Sessions fetched: ${classSessions.length}');
      sessions.assignAll(classSessions);

      // Load first page of students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClassId.value,
        limit: _reportPageSize,
        offset: 0,
      );
      debugPrint('Students fetched: ${classStudents.length}');
      students.assignAll(classStudents);
      _reportStudentsOffset = students.length;
      hasMoreStudentsInReport.value = classStudents.length == _reportPageSize;
      
      _filterStudents();

      // Reset statistics
      presentCount.value = 0;
      absentCount.value = 0;
      lateCount.value = 0;
      studentStats.clear();

      if (sessions.isEmpty) {
        debugPrint('No sessions found');
        averageAttendance.value = 0.0;
        return;
      }

      // Use high-performance individual student statistics (Edge Function)
      await _updateStudentStats();
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading attendance data: $e');
      TSnackBar.showError(
        message: 'Failed to load attendance data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update selected class and reload data
  Future<void> updateSelectedClass(String classId) async {
    if (selectedClassId.value != classId) {
      selectedClassId.value = classId;
      await loadAttendanceData();
    }
  }

  // Update date range and reload data
  Future<void> updateDateRange(
      DateTime newStartDate, DateTime newEndDate) async {
    startDate.value = newStartDate;
    endDate.value = newEndDate;

    if (selectedClassId.value.isNotEmpty) {
      await loadAttendanceData();
    }
  }

  // Navigate to student detail screen
  void navigateToStudentDetail(StudentModel student) {
    debugPrint('Navigating to student detail for: ${student.name}');
    Get.to(
      () =>
          StudentDetailScreen(student: student, classId: selectedClassId.value),
    );
  }

  // Export attendance report to CSV
  Future<void> exportAttendanceReport() async {
    try {
      if (selectedClassId.isEmpty || students.isEmpty || sessions.isEmpty) {
        debugPrint('No data available to export');
        TSnackBar.showInfo(message: 'No data available to export');
        return;
      }

      debugPrint('Exporting attendance report...');
      isLoading.value = true;

      final classModel = classes.firstWhere(
        (c) => c.id == selectedClassId.value,
      );
      final className =
          '${classModel.subjectName} - ${classModel.courseName} Semester ${classModel.semester}';

      final headerRow = [
        'Roll Number',
        'Student Name',
        'Present',
        'Absent',
        'Late',
        'Attendance %',
      ];

      for (var session in sessions) {
        headerRow.add(DateFormat('yyyy-MM-dd').format(session.date));
      }

      final dataRows = <List<dynamic>>[];

      // Sort students by roll number in ascending order
      final sortedStudents = List<StudentModel>.from(students);
      sortedStudents.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

      for (var student in sortedStudents) {
        final stats = studentStats[student.id];
        if (stats == null) continue;

        final row = [
          student.rollNumber,
          student.name,
          stats['presentCount'],
          stats['absentCount'],
          stats['lateCount'],
          '${stats['attendancePercentage'].toStringAsFixed(1)}%',
        ];

        for (var session in sessions) {
          final status = await attendanceService.getAttendanceStatusForSession(
            sessionId: session.id,
            studentId: student.id,
          );
          row.add(status.capitalize);
        }

        dataRows.add(row);
      }

      final summaryRow = [
        'TOTAL',
        '',
        presentCount.value,
        absentCount.value,
        lateCount.value,
        '${averageAttendance.value.toStringAsFixed(1)}%',
      ];

      for (var i = 0; i < sessions.length; i++) {
        summaryRow.add('');
      }

      dataRows.add(summaryRow);

      final csvData = [headerRow, ...dataRows];

      final csv = const ListToCsvConverter().convert(csvData);

      final directory = await getTemporaryDirectory();
      final fileName =
          'Attendance_${className}_${DateFormat('yyyy-MM-dd').format(startDate.value)}_to_${DateFormat('yyyy-MM-dd').format(endDate.value)}.csv';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csv);

      debugPrint('CSV file saved at: $filePath');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Attendance Report for $className',
        ),
      );

      TSnackBar.showSuccess(message: 'Report exported successfully');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error exporting report: $e');
      TSnackBar.showError(message: 'Failed to export report: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get connection status string for UI display
  String getConnectionStatus() {
    if (!isRealtimeConnected.value) {
      return 'Disconnected';
    }

    final now = DateTime.now();
    final difference = now.difference(lastUpdated.value);

    if (difference.inSeconds < 30) {
      return 'Live';
    } else if (difference.inSeconds < 60) {
      return 'Updated ${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    } else {
      return 'Updated ${difference.inHours}h ago';
    }
  }

  // Reconnect to real-time service
  Future<void> reconnectRealtime() async {
    try {
      debugPrint(
          'Attempting to reconnect to real-time service from AttendanceReportsController...');
      await realtimeService.forceReconnect();
      debugPrint('Successfully reconnected to real-time service');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Failed to reconnect to real-time service: $e');
    }
  }

  // Refresh all data manually
  Future<void> refreshData() async {
    try {
      debugPrint('Manually refreshing attendance reports data...');
      await loadClasses();
      if (selectedClassId.value.isNotEmpty) {
        await loadAttendanceData();
      }
      TSnackBar.showSuccess(message: 'Data refreshed successfully');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error refreshing data: $e');
      TSnackBar.showError(message: 'Failed to refresh data: ${e.toString()}');
    }
  }

}
