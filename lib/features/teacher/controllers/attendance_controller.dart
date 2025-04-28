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
  // final allSessionsController = Get.put(AllSessionsController());

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
  /// Sets the currently selected class and loads its attendance sessions.
  ///
  /// This function updates the `selectedClass` with the provided `classModel` and triggers
  /// the loading of attendance sessions associated with the class.
  ///
  /// [classModel] - The class model representing the selected class.

  void setSelectedClass(ClassModel classModel) {
    //printnt('Setting selected class: ${classModel.id}');
    selectedClass.value = classModel;
    loadAttendanceSessions(classModel.id);
  }

  // Load attendance sessions for a class
  // load attendance sessions

  Future<void> loadAttendanceSessions(String classId) async {
    try {
      //printnt('Loading attendance sessions for class: $classId');
      isLoading.value = true;

      final sessions = await attendanceService.getAttendanceSessions(classId);
      //printnt('Loaded ${sessions.length} attendance sessions');
      attendanceSessions.assignAll(sessions);

      // Load students for the class
      await loadStudentsForClass();
    } catch (e) {
      //printnt('Error loading attendance sessions: $e');
      TSnackBar.showError(
        message: 'Failed to load attendance sessions: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // load students for the class
  /// Loads students for the currently selected class.
  ///
  /// This function loads students for the class set in `selectedClass` and
  /// initializes their attendance status to 'absent'. It also sets the
  /// `isStudentsLoaded` flag.
  ///
  /// If the `selectedClass` is null, the function returns immediately without
  /// performing any action.
  Future<void> loadStudentsForClass() async {
    try {
      if (selectedClass.value == null) {
        //printnt('No class selected, returning');
        return;
      }

      //printnt('Loading students for class: ${selectedClass.value!.id}');
      isLoading.value = true;

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClass.value!.id,
      );

      //printnt('Loaded ${classStudents.length} students');

      // Initialize attendance status for all students
      for (var student in classStudents) {
        student.attendanceStatus = 'absent'; // Default status
      }

      students.assignAll(classStudents);
      isStudentsLoaded.value = true;
    } catch (e) {
      //printnt('Error loading students: $e');
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load students for the current session
  /// Loads students for the currently selected session.
  ///
  /// This function retrieves the list of students for the class associated
  /// with the currently selected session, and it attempts to load existing
  /// attendance records for these students. If attendance records exist, it
  /// updates each student's attendance status accordingly; otherwise, it
  /// defaults the status to 'absent'. The `isStudentsLoaded` flag is set upon
  /// successful loading of students.
  ///
  /// If no session is selected or if no class is associated with the selected
  /// session, the function returns immediately without performing any action.

  Future<void> loadStudentsForSession() async {
    try {
      if (currentSessionId.value.isEmpty || selectedClass.value == null) {
        //printnt('No session or class selected, returning');
        return;
      }

      //printnt('Loading students for session: ${currentSessionId.value}');
      isLoading.value = true;

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClass.value!.id,
      );

      //printnt('Loaded ${classStudents.length} students');

      // Load existing attendance records for this session
      final attendanceRecords = await attendanceService
          .getAttendanceRecordsForSession(currentSessionId.value);

      //printnt('Loaded ${attendanceRecords.length} attendance records');

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
      //printnt('Error loading students for session: $e');
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update a student's attendance status
  /// Updates the attendance status of a student.
  ///
  /// This function finds the student in the list by their ID and updates
  /// their attendance status with the provided status. If the student is
  /// found, the list is refreshed to reflect the change.
  ///
  /// [studentId] The ID of the student whose status is to be updated.
  /// [status] The new attendance status to assign to the student.

  void updateStudentStatus(String studentId, String status) {
    //printnt('Updating status for student $studentId to: $status');
    final index = students.indexWhere((student) => student.id == studentId);
    if (index != -1) {
      final student = students[index];
      student.attendanceStatus = status;
      students[index] = student;
      students.refresh();
      //printnt('Student status updated successfully');
    } else {
      //printnt('Student not found in the list');
    }
  }

  // Update the submitAttendance method

  Future<void> submitAttendance() async {
    try {
      isLoading.value = true;

      if (currentSessionId.value.isEmpty) {
        //printnt('No session selected, cannot submit attendance');
        TSnackBar.showError(message: 'No session selected');
        return;
      }

      //printnt('Submitting attendance for session: ${currentSessionId.value}');

      // Prepare attendance records
      final records = students
          .map(
            (student) => {
              'student_id': student.id,
              'status': student.attendanceStatus ?? 'absent',
              'remarks': '',
            },
          )
          .toList();

      //printnt('Submitting ${records.length} attendance records');

      // Submit attendance records
      await attendanceService.submitBulkAttendance(
        sessionId: currentSessionId.value,
        records: records,
      );

      // await allSessionsController.closeSession(currentSessionId.value);
      // Show success message and navigate back
      TSnackBar.showSuccess(
        message: 'Attendance submitted and session closed',
        title: 'Success',
      );
      Get.back();

      // Close the session after submitting attendance
      await attendanceService.closeAttendanceSession(currentSessionId.value);

      // Reload the attendance sessions to reflect the updated status
      if (selectedClass.value != null) {
        await loadAttendanceSessions(selectedClass.value!.id);
      }

      //printnt('Attendance submitted and session closed successfully');

      TSnackBar.showSuccess(
        message: 'Attendance submitted and session closed successfully',
        title: 'Success',
      );

      // Navigate back to attendance screen
      Get.back();
    } catch (e) {
      //printnt('Error submitting attendance: $e');
      TSnackBar.showError(
        message: 'Failed to submit attendance: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new attendance session
  /// Create a new attendance session for the currently selected class.
  ///
  /// The session's date is set to the current [sessionDate] and the start
  /// and end times are set to the values of [startTimeController] and
  /// [endTimeController] respectively. If either of the time controllers is
  /// empty, the corresponding time is set to null.
  ///
  /// The session is created by the currently logged in user, and the session
  /// is created with the [selectedClass] as its class.
  ///
  /// After creating the session, the attendance sessions for the class are
  /// reloaded and the dialog is closed with a success message.
  ///
  /// If there is an error while creating the session, an error message is
  /// shown and the dialog is not closed.
  Future<void> createAttendanceSession() async {
    try {
      isLoading.value = true;

      if (selectedClass.value == null) {
        //printnt('No class selected, cannot create session');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        //printnt('No user logged in');
        TSnackBar.showError(
          message: 'You must be logged in to create a session',
        );
        return;
      }

      //printnt('Creating attendance session for class: ${selectedClass.value!.id}');
      //printnt('Session date: ${sessionDate.value}');
      //printnt('Start time: ${startTimeController.text}');
      //printnt('End time: ${endTimeController.text}');

      // Create the session
      await attendanceService.createAttendanceSession(
        classId: selectedClass.value!.id,
        date: sessionDate.value,
        startTime:
            startTimeController.text.isEmpty ? null : startTimeController.text,
        endTime: endTimeController.text.isEmpty ? null : endTimeController.text,
        createdBy: currentUser.id,
      );

      //printnt('Session created successfully');

      // Reload sessions
      await loadAttendanceSessions(selectedClass.value!.id);

      // Close dialog
      Get.back();

      TSnackBar.showSuccess(
        message: 'Attendance session created successfully',
        title: 'Success',
      );
    } catch (e) {
      //printnt('Error creating attendance session: $e');
      TSnackBar.showError(message: 'Failed to create session: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Add this method to check if a session is currently running
  // Update the isSessionRunning method to check the status column

  bool isSessionRunning(String sessionId) {
    try {
      // Find the session in the list
      final session =
          attendanceSessions.firstWhereOrNull((s) => s.id == sessionId);
      if (session == null) return false;

      // If the session is explicitly marked as closed, return false
      if (session.status == 'closed') return false;

      final now = DateTime.now();
      final sessionDate = session.date;

      // Debug information
      print('Checking if session is running:');
      print('Session ID: $sessionId');
      print('Session date: $sessionDate');
      print('Current date: $now');
      print('Session start time: ${session.startTime}');
      print('Session end time: ${session.endTime}');

      // Check if the session is today
      if (sessionDate.year == now.year &&
          sessionDate.month == now.month &&
          sessionDate.day == now.day) {
        // If there's no specific time, consider it running all day
        if (session.startTime == null || session.endTime == null) {
          print('No specific time set, considering session running all day');
          return true;
        }

        // Parse the time strings with AM/PM format
        DateTime? sessionStart;
        DateTime? sessionEnd;

        // Try to parse different time formats
        try {
          // First try format like "10:00 AM"
          if (session.startTime!.toLowerCase().contains('am') ||
              session.startTime!.toLowerCase().contains('pm')) {
            final startTimeParts = session.startTime!.split(':');
            final hour = int.parse(startTimeParts[0]);
            final minutePart = startTimeParts[1].split(' ');
            final minute = int.parse(minutePart[0]);
            final ampm = minutePart[1].toLowerCase();

            int adjustedHour = hour;
            if (ampm == 'pm' && hour < 12) {
              adjustedHour += 12;
            } else if (ampm == 'am' && hour == 12) {
              adjustedHour = 0;
            }

            sessionStart =
                DateTime(now.year, now.month, now.day, adjustedHour, minute);
          } else {
            // Try 24-hour format
            final startTimeParts = session.startTime!.split(':');
            final hour = int.parse(startTimeParts[0]);
            final minute = int.parse(startTimeParts[1]);
            sessionStart = DateTime(now.year, now.month, now.day, hour, minute);
          }

          // Parse end time similarly
          if (session.endTime!.toLowerCase().contains('am') ||
              session.endTime!.toLowerCase().contains('pm')) {
            final endTimeParts = session.endTime!.split(':');
            final hour = int.parse(endTimeParts[0]);
            final minutePart = endTimeParts[1].split(' ');
            final minute = int.parse(minutePart[0]);
            final ampm = minutePart[1].toLowerCase();

            int adjustedHour = hour;
            if (ampm == 'pm' && hour < 12) {
              adjustedHour += 12;
            } else if (ampm == 'am' && hour == 12) {
              adjustedHour = 0;
            }

            sessionEnd =
                DateTime(now.year, now.month, now.day, adjustedHour, minute);
          } else {
            // Try 24-hour format
            final endTimeParts = session.endTime!.split(':');
            final hour = int.parse(endTimeParts[0]);
            final minute = int.parse(endTimeParts[1]);
            sessionEnd = DateTime(now.year, now.month, now.day, hour, minute);
          }

          print('Parsed start time: $sessionStart');
          print('Parsed end time: $sessionEnd');
          print('Current time: $now');

          // Check if current time is between start and end
          bool isAfterStart = now.isAfter(sessionStart);
          bool isBeforeEnd = now.isBefore(sessionEnd);
          print('Is after start: $isAfterStart');
          print('Is before end: $isBeforeEnd');

          return isAfterStart && isBeforeEnd;
        } catch (e) {
          print('Error parsing session time: $e');
          // If parsing fails, default to running
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error in isSessionRunning: $e');
      return false;
    }
  }

  @override
  void onClose() {
    //printnt('Disposing controllers');
    startTimeController.dispose();
    endTimeController.dispose();
    super.onClose();
  }
}
