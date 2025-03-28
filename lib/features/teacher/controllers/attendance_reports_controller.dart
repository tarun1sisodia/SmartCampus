import 'package:attedance__/features/teacher/screens/student_detail_screen.dart';
import 'package:attedance__/models/attendance_session_model.dart';
import 'package:attedance__/models/class_model.dart';
import 'package:attedance__/models/student_model.dart';
import 'package:attedance__/services/attendance_service.dart';
import 'package:attedance__/services/class_service.dart';
import 'package:attedance__/services/student_service.dart';
import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart'; // Ensure this import is present
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceReportsController extends GetxController {
  final attendanceService = AttendanceService();
  final classService = ClassService();
  final studentService = StudentService();

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

  // Map to store attendance stats for each
  // Map to store attendance stats for each student
  final studentStats = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadClasses();
  }

  // Load all classes for the current teacher
  Future<void> loadClasses() async {
    try {
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(message: 'You must be logged in to view reports');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );
      classes.assignAll(teacherClasses);

      if (classes.isNotEmpty && selectedClassId.isEmpty) {
        selectedClassId.value = classes[0].id;
        await loadAttendanceData();
      }
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load attendance data for the selected class and date range
  Future<void> loadAttendanceData() async {
    try {
      if (selectedClassId.isEmpty) return;

      isLoading.value = true;

      // Load sessions for the selected date range
      final classSessions = await attendanceService
          .getAttendanceSessionsForDateRange(
            classId: selectedClassId.value,
            startDate: startDate.value,
            endDate: endDate.value,
          );
      sessions.assignAll(classSessions);

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClassId.value,
      );
      students.assignAll(classStudents);

      // Reset statistics
      presentCount.value = 0;
      absentCount.value = 0;
      lateCount.value = 0;
      studentStats.clear();

      // If no sessions, return early
      if (sessions.isEmpty) {
        averageAttendance.value = 0.0;
        return;
      }

      // Calculate overall statistics
      final stats = await attendanceService.getAttendanceStatsForDateRange(
        classId: selectedClassId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      presentCount.value = stats['presentCount'] ?? 0;
      absentCount.value = stats['absentCount'] ?? 0;
      lateCount.value = stats['lateCount'] ?? 0;
      averageAttendance.value = stats['averageAttendance'] ?? 0.0;

      // Calculate statistics for each student
      for (var student in students) {
        final studentStat = await attendanceService
            .getAttendanceStatsForStudentInDateRange(
              classId: selectedClassId.value,
              studentId: student.id,
              startDate: startDate.value,
              endDate: endDate.value,
            );

        studentStats[student.id] = studentStat;
      }
    } catch (e) {
      TSnackBar.showError(
        message: 'Failed to load attendance data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to student detail screen
  void navigateToStudentDetail(StudentModel student) {
    Get.to(
      () =>
          StudentDetailScreen(student: student, classId: selectedClassId.value),
    );
  }

  // Export attendance report as CSV
  Future<void> exportAttendanceReport() async {
    try {
      if (selectedClassId.isEmpty || students.isEmpty || sessions.isEmpty) {
        TSnackBar.showInfo(message: 'No data available to export');
        return;
      }

      isLoading.value = true;

      // Get class details
      final classModel = classes.firstWhere(
        (c) => c.id == selectedClassId.value,
      );
      final className =
          '${classModel.subjectName} - ${classModel.courseName} Year ${classModel.year}';

      // Create CSV header row
      final headerRow = [
        'Roll Number',
        'Student Name',
        'Present',
        'Absent',
        'Late',
        'Attendance %',
      ];

      // Add session dates to header
      for (var session in sessions) {
        headerRow.add(DateFormat('yyyy-MM-dd').format(session.date));
      }

      // Create data rows
      final dataRows = <List<dynamic>>[];

      for (var student in students) {
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

        // Add attendance status for each session
        for (var session in sessions) {
          final status = await attendanceService.getAttendanceStatusForSession(
            sessionId: session.id,
            studentId: student.id,
          );
          row.add(status.capitalize);
        }

        dataRows.add(row);
      }

      // Add summary row
      final summaryRow = [
        'TOTAL',
        '',
        presentCount.value,
        absentCount.value,
        lateCount.value,
        '${averageAttendance.value.toStringAsFixed(1)}%',
      ];

      // Add empty cells for session dates
      for (var i = 0; i < sessions.length; i++) {
        summaryRow.add('');
      }

      dataRows.add(summaryRow);

      // Convert to CSV
      final csvData = [headerRow, ...dataRows];

      final csv = const ListToCsvConverter().convert(csvData);

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final fileName =
          'Attendance_${className}_${DateFormat('yyyy-MM-dd').format(startDate.value)}_to_${DateFormat('yyyy-MM-dd').format(endDate.value)}.csv';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csv);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Attendance Report for $className',
      );

      TSnackBar.showSuccess(message: 'Report exported successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to export report: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
