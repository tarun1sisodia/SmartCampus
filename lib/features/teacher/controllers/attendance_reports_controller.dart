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

  // Map to store attendance stats for each student
  final studentStats = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    print('AttendanceReportsController initialized');
    loadClasses();
  }

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

  Future<void> loadAttendanceData() async {
    try {
      if (selectedClassId.isEmpty) {
        print('No class selected');
        return;
      }

      print('Loading attendance data for class: ${selectedClassId.value}');
      isLoading.value = true;

      final classSessions = await attendanceService
          .getAttendanceSessionsForDateRange(
            classId: selectedClassId.value,
            startDate: startDate.value,
            endDate: endDate.value,
          );
      print('Sessions fetched: ${classSessions.length}');
      sessions.assignAll(classSessions);

      final classStudents = await studentService.getStudentsForClass(
        selectedClassId.value,
      );
      print('Students fetched: ${classStudents.length}');
      students.assignAll(classStudents);

      presentCount.value = 0;
      absentCount.value = 0;
      lateCount.value = 0;
      studentStats.clear();

      if (sessions.isEmpty) {
        print('No sessions found');
        averageAttendance.value = 0.0;
        return;
      }

      final stats = await attendanceService.getAttendanceStatsForDateRange(
        classId: selectedClassId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      presentCount.value = stats['presentCount'] ?? 0;
      absentCount.value = stats['absentCount'] ?? 0;
      lateCount.value = stats['lateCount'] ?? 0;
      averageAttendance.value = stats['averageAttendance'] ?? 0.0;

      print('Overall stats - Present: ${presentCount.value}, Absent: ${absentCount.value}, Late: ${lateCount.value}, Average: ${averageAttendance.value}');

      for (var student in students) {
        final studentStat = await attendanceService
            .getAttendanceStatsForStudentInDateRange(
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

  void navigateToStudentDetail(StudentModel student) {
    print('Navigating to student detail for: ${student.name}');
    Get.to(
      () =>
          StudentDetailScreen(student: student, classId: selectedClassId.value),
    );
  }

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

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Attendance Report for $className',
      );

      TSnackBar.showSuccess(message: 'Report exported successfully');
    } catch (e) {
      print('Error exporting report: $e');
      TSnackBar.showError(message: 'Failed to export report: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
