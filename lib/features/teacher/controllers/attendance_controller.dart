import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../models/student_model.dart';
import '../../../models/attendance_session_model.dart';
import '../../../services/class_service.dart';
import '../../../services/student_service.dart';
import '../../../services/attendance_service.dart';
import '../../../utils/helpers/snackbar_helper.dart';

class AttendanceController extends GetxController {
  final classService = ClassService();
  final studentService = StudentService();
  final attendanceService = AttendanceService();
  
  final isLoading = false.obs;
  final selectedClass = Rxn<ClassModel>();
  final students = <StudentModel>[].obs;
  final attendanceSessions = <AttendanceSessionModel>[].obs;
  
  // For creating a new session
  final sessionDate = DateTime.now().obs;
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  
  // For tracking attendance
  final currentSessionId = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
  }
  
  @override
  void onClose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.onClose();
  }
  
  // Set the selected class and load its data
  Future<void> setSelectedClass(ClassModel classModel) async {
    selectedClass.value = classModel;
    await loadStudentsForClass(classModel.id);
    await loadAttendanceSessions(classModel.id);
  }
  
  // Load students for a class
  Future<void> loadStudentsForClass(String classId) async {
    try {
      isLoading.value = true;
      
      final classStudents = await studentService.getStudentsForClass(classId);
      
      // Initialize all students with no attendance status
      for (var student in classStudents) {
        student.attendanceStatus = null;
      }
      
      students.assignAll(classStudents);
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load attendance sessions for a class
  Future<void> loadAttendanceSessions(String classId) async {
    try {
      isLoading.value = true;
      
      final sessions = await attendanceService.getAttendanceSessionsForClass(classId);
      
      attendanceSessions.assignAll(sessions);
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load attendance sessions: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Create a new attendance session
  Future<void> createAttendanceSession() async {
    try {
      if (selectedClass.value == null) {
        TSnackBar.showError(message: 'No class selected');
        return;
      }
      
      isLoading.value = true;
      
      final teacherId = Supabase.instance.client.auth.currentUser!.id;
      
      final session = await attendanceService.createAttendanceSession(
        classId: selectedClass.value!.id,
        date: sessionDate.value,
        startTime: startTimeController.text.isNotEmpty ? startTimeController.text : null,
        endTime: endTimeController.text.isNotEmpty ? endTimeController.text : null,
        createdBy: teacherId,
      );
      
      // Set the current session ID for attendance tracking
      currentSessionId.value = session.id;
      
      // Add to the list
      attendanceSessions.insert(0, session);
      
      // Reset form
      startTimeController.clear();
      endTimeController.clear();
      
      TSnackBar.showSuccess(message: 'Attendance session created successfully');
      
      // Close the dialog
      Get.back();
    } catch (e) {
      TSnackBar.showError(message: 'Failed to create attendance session: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Mark a student as present
  void markStudentPresent(int index) {
    if (index >= 0 && index < students.length) {
      students[index].attendanceStatus = 'present';
      students.refresh();
    }
  }
  
  // Mark a student as absent
  void markStudentAbsent(int index) {
    if (index >= 0 && index < students.length) {
      students[index].attendanceStatus = 'absent';
      students.refresh();
    }
  }
  
  // Submit attendance for the current session
  Future<void> submitAttendance() async {
    try {
      if (currentSessionId.value.isEmpty) {
        TSnackBar.showError(message: 'No active attendance session');
        return;
      }
      
      // Check if all students have an attendance status
      final unmarkedStudents = students.where((s) => s.attendanceStatus == null).length;
      if (unmarkedStudents > 0) {
        Get.dialog(
          AlertDialog(
            title: Text('Unmarked Students'),
            content: Text('There are $unmarkedStudents students without attendance. They will be marked as absent by default. Continue?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _submitAttendanceRecords();
                },
                child: Text('Continue'),
              ),
            ],
          ),
        );
        return;
      }
      
      await _submitAttendanceRecords();
    } catch (e) {
      TSnackBar.showError(message: 'Failed to submit attendance: ${e.toString()}');
    }
  }
  
  // Private method to submit attendance records
  Future<void> _submitAttendanceRecords() async {
    try {
      isLoading.value = true;
      
      await attendanceService.submitAttendanceRecords(
        sessionId: currentSessionId.value,
        students: students,
      );
      
      // Reset student attendance status
      for (var student in students) {
        student.attendanceStatus = null;
      }
      students.refresh();
      
      // Reset current session
      currentSessionId.value = '';
      
      TSnackBar.showSuccess(message: 'Attendance submitted successfully');
      
      // Navigate back to the class screen
      Get.back();
    } catch (e) {
      TSnackBar.showError(message: 'Failed to submit attendance: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
