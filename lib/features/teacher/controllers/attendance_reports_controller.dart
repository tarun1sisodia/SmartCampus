import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // Map to store attendance stats for each student
  final studentStats = <String, Map<String, dynamic>>{}.obs;

  // Real-time connection status
  final isRealtimeConnected = true.obs;
  final lastUpdated = DateTime.now().obs;

  // Filtered data
  final filteredStudents = <StudentModel>[].obs;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    print('AttendanceReportsController initialized');
    _initializeRealtimeService();
    loadClasses();
  }

  @override
  void onClose() {
    print('AttendanceReportsController disposed');

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
      print(
          'Found existing RealtimeService instance in AttendanceReportsController');
    } catch (e) {
      print(
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
        print(
            'Real-time classes update in AttendanceReportsController: ${data.length} classes');
        _handleClassesUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        print('Error in classes stream (AttendanceReportsController): $error');
        isRealtimeConnected.value = false;
      },
    );

    // Subscribe to attendance sessions stream
    final attendanceSessionsSubscription =
        realtimeService.attendanceSessionsStream.listen(
      (data) {
        print(
            'Real-time attendance sessions update in AttendanceReportsController: ${data.length} sessions');
        _handleAttendanceSessionsUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        print(
            'Error in attendance sessions stream (AttendanceReportsController): $error');
      },
    );

    // Subscribe to attendance records stream
    final attendanceRecordsSubscription =
        realtimeService.attendanceRecordsStream.listen(
      (data) {
        print(
            'Real-time attendance records update in AttendanceReportsController: ${data.length} records');
        _handleAttendanceRecordsUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        print(
            'Error in attendance records stream (AttendanceReportsController): $error');
      },
    );

    // Subscribe to students stream
    final studentsSubscription = realtimeService.studentsStream.listen(
      (data) {
        print(
            'Real-time students update in AttendanceReportsController: ${data.length} students');
        _handleStudentsUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        print('Error in students stream (AttendanceReportsController): $error');
      },
    );

    // Monitor RealtimeService connection status
    final connectionSubscription = realtimeService.isConnected.listen(
      (isConnected) {
        isRealtimeConnected.value = isConnected;
        if (isConnected) {
          print('Real-time connection restored in AttendanceReportsController');
          // Refresh data when connection is restored
          loadClasses();
          if (selectedClassId.value.isNotEmpty) {
            loadAttendanceData();
          }
        } else {
          print('Real-time connection lost in AttendanceReportsController');
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
            print(
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

      print(
          'AttendanceReportsController classes updated via real-time: ${teacherClasses.length} classes');
    } catch (e) {
      print('Error handling classes update in AttendanceReportsController: $e');
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

      print(
          'AttendanceReportsController sessions updated via real-time: ${classSessions.length} sessions');
    } catch (e) {
      print(
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

      print(
          'AttendanceReportsController attendance records updated via real-time: ${relevantRecords.length} relevant records');
    } catch (e) {
      print(
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

      print('AttendanceReportsController students updated via real-time');
    } catch (e) {
      print(
          'Error handling students update in AttendanceReportsController: $e');
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
    } catch (e) {
      print('Error loading students for class: $e');
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
    } catch (e) {
      print('Error recalculating statistics: $e');
      _resetStatistics();
    }
  }

  // Update individual student statistics
  Future<void> _updateStudentStats() async {
    if (selectedClassId.value.isEmpty || students.isEmpty) return;

    try {
      final newStudentStats = <String, Map<String, dynamic>>{};

      for (var student in students) {
        final studentStat =
            await attendanceService.getAttendanceStatsForStudentInDateRange(
          classId: selectedClassId.value,
          studentId: student.id,
          startDate: startDate.value,
          endDate: endDate.value,
        );

        newStudentStats[student.id] = studentStat;
      }

      studentStats.assignAll(newStudentStats);
    } catch (e) {
      print('Error updating student stats: $e');
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
      print('Loading classes...');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('User not authenticated');
        TSnackBar.showError(message: 'You must be logged in to view reports');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );
      print('Classes fetched: ${teacherClasses.length}');
      classes.assignAll(teacherClasses);

      if (classes.isNotEmpty && selectedClassId.isEmpty) {
        selectedClassId.value = classes[0].id;
        print('Selected class ID: ${selectedClassId.value}');
        await loadAttendanceData();
      }
    } catch (e) {
      print('Error loading classes: $e');
      TSnackBar.showError(message: 'Failed to load classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load attendance data for the selected class and date range
  Future<void> loadAttendanceData() async {
    try {
      if (selectedClassId.isEmpty) {
        print('No class selected');
        return;
      }

      print('Loading attendance data for class: ${selectedClassId.value}');
      isLoading.value = true;

      // Load sessions for the date range
      final classSessions =
          await attendanceService.getAttendanceSessionsForDateRange(
        classId: selectedClassId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      print('Sessions fetched: ${classSessions.length}');
      sessions.assignAll(classSessions);

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClassId.value,
      );
      print('Students fetched: ${classStudents.length}');
      students.assignAll(classStudents);
      _filterStudents();

      // Reset statistics
      presentCount.value = 0;
      absentCount.value = 0;
      lateCount.value = 0;
      studentStats.clear();

      if (sessions.isEmpty) {
        print('No sessions found');
        averageAttendance.value = 0.0;
        return;
      }

      // Load overall statistics
      final stats = await attendanceService.getAttendanceStatsForDateRange(
        classId: selectedClassId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      presentCount.value = stats['presentCount'] ?? 0;
      absentCount.value = stats['absentCount'] ?? 0;
      lateCount.value = stats['lateCount'] ?? 0;
      averageAttendance.value = stats['averageAttendance'] ?? 0.0;

      print(
          'Overall stats - Present: ${presentCount.value}, Absent: ${absentCount.value}, Late: ${lateCount.value}, Average: ${averageAttendance.value}');

      // Load individual student statistics
      for (var student in students) {
        final studentStat =
            await attendanceService.getAttendanceStatsForStudentInDateRange(
          classId: selectedClassId.value,
          studentId: student.id,
          startDate: startDate.value,
          endDate: endDate.value,
        );

        studentStats[student.id] = studentStat;
        print('Stats for student ${student.name}: $studentStat');
      }
    } catch (e) {
      print('Error loading attendance data: $e');
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
    print('Navigating to student detail for: ${student.name}');
    Get.to(
      () =>
          StudentDetailScreen(student: student, classId: selectedClassId.value),
    );
  }

  // Export attendance report to CSV
  Future<void> exportAttendanceReport() async {
    try {
      if (selectedClassId.isEmpty || students.isEmpty || sessions.isEmpty) {
        print('No data available to export');
        TSnackBar.showInfo(message: 'No data available to export');
        return;
      }

      print('Exporting attendance report...');
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

      print('CSV file saved at: $filePath');

      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Attendance Report for $className');

      TSnackBar.showSuccess(message: 'Report exported successfully');
    } catch (e) {
      print('Error exporting report: $e');
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
      print(
          'Attempting to reconnect to real-time service from AttendanceReportsController...');
      await realtimeService.forceReconnect();
      print('Successfully reconnected to real-time service');
    } catch (e) {
      print('Failed to reconnect to real-time service: $e');
    }
  }

  // Refresh all data manually
  Future<void> refreshData() async {
    try {
      print('Manually refreshing attendance reports data...');
      await loadClasses();
      if (selectedClassId.value.isNotEmpty) {
        await loadAttendanceData();
      }
      TSnackBar.showSuccess(message: 'Data refreshed successfully');
    } catch (e) {
      print('Error refreshing data: $e');
      TSnackBar.showError(message: 'Failed to refresh data: ${e.toString()}');
    }
  }

  // Get filtered students based on search query
  List<StudentModel> get displayStudents {
    return filteredStudents;
  }

  // Get student statistics for a specific student
  Map<String, dynamic>? getStudentStats(String studentId) {
    return studentStats[studentId];
  }

  // Check if data is available for display
  bool get hasData {
    return classes.isNotEmpty &&
        selectedClassId.value.isNotEmpty &&
        students.isNotEmpty;
  }

  // Check if there are any sessions in the selected date range
  bool get hasSessions {
    return sessions.isNotEmpty;
  }

  // Get the currently selected class
  ClassModel? get selectedClass {
    if (selectedClassId.value.isEmpty) return null;
    return classes.firstWhereOrNull((c) => c.id == selectedClassId.value);
  }

  // Get attendance percentage for a specific student
  double getStudentAttendancePercentage(String studentId) {
    final stats = studentStats[studentId];
    if (stats == null) return 0.0;
    return stats['attendancePercentage']?.toDouble() ?? 0.0;
  }

  // Get total sessions count for the selected date range
  int get totalSessions {
    return sessions.length;
  }

  // Get total students count
  int get totalStudents {
    return students.length;
  }

  // Calculate class average attendance
  double get classAverageAttendance {
    if (students.isEmpty) return 0.0;

    double totalPercentage = 0.0;
    int validStudents = 0;

    for (var student in students) {
      final stats = studentStats[student.id];
      if (stats != null) {
        totalPercentage += stats['attendancePercentage']?.toDouble() ?? 0.0;
        validStudents++;
      }
    }

    return validStudents > 0 ? totalPercentage / validStudents : 0.0;
  }

  // Get students with low attendance (below threshold)
  List<StudentModel> getLowAttendanceStudents({double threshold = 75.0}) {
    return students.where((student) {
      final percentage = getStudentAttendancePercentage(student.id);
      return percentage < threshold;
    }).toList();
  }

  // Get students with perfect attendance
  List<StudentModel> getPerfectAttendanceStudents() {
    return students.where((student) {
      final percentage = getStudentAttendancePercentage(student.id);
      return percentage >= 100.0;
    }).toList();
  }

  // Sort students by attendance percentage
  List<StudentModel> getStudentsSortedByAttendance({bool ascending = false}) {
    final sortedStudents = List<StudentModel>.from(students);
    sortedStudents.sort((a, b) {
      final aPercentage = getStudentAttendancePercentage(a.id);
      final bPercentage = getStudentAttendancePercentage(b.id);

      return ascending
          ? aPercentage.compareTo(bPercentage)
          : bPercentage.compareTo(aPercentage);
    });

    return sortedStudents;
  }
}
