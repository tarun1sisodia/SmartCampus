import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../models/student_model.dart';
import '../../../models/attendance_session_model.dart';
import '../../../services/class_service.dart';
import '../../../services/student_service.dart';
import '../../../services/attendance_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class AttendanceController extends GetxController {
  final attendanceService = AttendanceService();
  final studentService = StudentService();
  final classService = ClassService();

  final isLoading = false.obs;
  final isStudentsLoaded = false.obs;
  final students = <StudentModel>[].obs;
  final currentSessionId = ''.obs;
  final selectedClass = Rx<ClassModel?>(null);
  final attendanceSessions = <AttendanceSessionModel>[].obs;

  // For creating new sessions
  final sessionDate = DateTime.now().obs;
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  // Set the selected class
  void setSelectedClass(ClassModel classModel) {
    selectedClass.value = classModel;
    loadAttendanceSessions(classModel.id);
  }

  // Load attendance sessions for a class
  // Add this method to load attendance sessions
  Future<void> loadAttendanceSessions(String classId) async {
    try {
      isLoading.value = true;

      final sessions = await attendanceService.getAttendanceSessions(classId);
      attendanceSessions.assignAll(sessions);

      // Load students for the class
      await loadStudentsForClass();
    } catch (e) {
      TSnackBar.showError(
        message: 'Failed to load attendance sessions: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add this method to load students for the class
  Future<void> loadStudentsForClass() async {
    try {
      if (selectedClass.value == null) return;

      isLoading.value = true;

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClass.value!.id,
      );

      // Initialize attendance status for all students
      for (var student in classStudents) {
        student.attendanceStatus = 'absent'; // Default status
      }

      students.assignAll(classStudents);
      isStudentsLoaded.value = true;
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load students for the current session
  Future<void> loadStudentsForSession() async {
    try {
      if (currentSessionId.value.isEmpty || selectedClass.value == null) {
        return;
      }

      isLoading.value = true;

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClass.value!.id,
      );

      // Load existing attendance records for this session
      final attendanceRecords = await attendanceService
          .getAttendanceRecordsForSession(currentSessionId.value);

      // Map attendance records to students
      for (var student in classStudents) {
        final record = attendanceRecords.firstWhereOrNull(
          (record) => record.studentId == student.id,
        );

        student.attendanceStatus = record?.status ?? 'absent';
      }

      students.assignAll(classStudents);
      isStudentsLoaded.value = true;
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update a student's attendance status
  void updateStudentStatus(String studentId, String status) {
    final index = students.indexWhere((student) => student.id == studentId);
    if (index != -1) {
      final student = students[index];
      student.attendanceStatus = status;
      students[index] = student;
      students.refresh();
    }
  }

  // Submit attendance for all students
  Future<void> submitAttendance() async {
    try {
      isLoading.value = true;

      if (currentSessionId.value.isEmpty) {
        TSnackBar.showError(message: 'No session selected');
        return;
      }

      // Prepare attendance records
      final records =
          students
              .map(
                (student) => {
                  'student_id': student.id,
                  'status': student.attendanceStatus ?? 'absent',
                  'remarks': '',
                },
              )
              .toList();

      // Submit attendance records
      await attendanceService.submitBulkAttendance(
        sessionId: currentSessionId.value,
        records: records,
      );

      TSnackBar.showSuccess(
        message: 'Attendance submitted successfully',
        title: 'Success',
      );

      // Navigate back to attendance screen
      Get.back();
    } catch (e) {
      TSnackBar.showError(
        message: 'Failed to submit attendance: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new attendance session
  Future<void> createAttendanceSession() async {
    try {
      isLoading.value = true;

      if (selectedClass.value == null) {
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(
          message: 'You must be logged in to create a session',
        );
        return;
      }

      // Create the session
      final session = await attendanceService.createAttendanceSession(
        classId: selectedClass.value!.id,
        date: sessionDate.value,
        startTime:
            startTimeController.text.isEmpty ? null : startTimeController.text,
        endTime: endTimeController.text.isEmpty ? null : endTimeController.text,
        createdBy: currentUser.id,
      );

      // Reload sessions
      await loadAttendanceSessions(selectedClass.value!.id);

      // Close dialog
      Get.back();

      TSnackBar.showSuccess(
        message: 'Attendance session created successfully',
        title: 'Success',
      );
    } catch (e) {
      TSnackBar.showError(message: 'Failed to create session: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.onClose();
  }
}
