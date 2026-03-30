import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:intl/intl.dart';
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
  static const int _sessionPageSize = 20;
  // final allSessionsController = Get.put(AllSessionsController());

  final isLoading = false.obs;
  final isStudentsLoaded = false.obs;
  final students = <StudentModel>[].obs;
  final currentSessionId = ''.obs;
  final selectedClass = Rx<ClassModel?>(null);
  final attendanceSessions = <AttendanceSessionModel>[].obs;
  final hasMoreSessions = true.obs;
  final isLoadingMoreSessions = false.obs;
  int _sessionOffset = 0;

  final hasMoreStudents = true.obs;
  final isLoadingMoreStudents = false.obs;
  int _studentsOffset = 0;
  static const int _studentsPageSize = 25;

  // For creating new sessions
  final sessionDate = DateTime.now().obs;
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  // Set the selected class
  // Sets the currently selected class and loads its attendance sessions.
  //
  // This function updates the `selectedClass` with the provided `classModel` and triggers
  // the loading of attendance sessions associated with the class.
  //
  // [classModel] - The class model representing the selected class.

  void setSelectedClass(ClassModel classModel) {
    //printnt('Setting selected class: ${classModel.id}');
    selectedClass.value = classModel;
    loadAttendanceSessions(classModel.id);
  }

  // Load attendance sessions for a class
  // load attendance sessions

  Future<void> loadAttendanceSessions(String classId) async {
    await loadAttendanceSessionsPage(classId, reset: true);
  }

  Future<void> loadAttendanceSessionsPage(
    String classId, {
    bool reset = false,
  }) async {
    try {
      //printnt('Loading attendance sessions for class: $classId');
      if (reset) {
        isLoading.value = true;
        _sessionOffset = 0;
        hasMoreSessions.value = true;
      } else {
        if (isLoading.value ||
            isLoadingMoreSessions.value ||
            !hasMoreSessions.value) {
          return;
        }
        isLoadingMoreSessions.value = true;
      }

      final sessions = await attendanceService.getAttendanceSessions(
        classId,
        limit: _sessionPageSize,
        offset: _sessionOffset,
      );
      //printnt('Loaded ${sessions.length} attendance sessions');
      if (reset) {
        attendanceSessions.assignAll(sessions);
      } else {
        attendanceSessions.addAll(sessions);
      }
      _sessionOffset = attendanceSessions.length;
      hasMoreSessions.value = sessions.length == _sessionPageSize;

      if (reset) {
        await loadStudentsForClass();
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      //printnt('Error loading attendance sessions: $e');
      TSnackBar.showError(
        message: 'Failed to load attendance sessions: ${e.toString()}',
      );
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMoreSessions.value = false;
      }
    }
  }

  Future<void> loadMoreAttendanceSessions() async {
    if (selectedClass.value == null) return;
    await loadAttendanceSessionsPage(selectedClass.value!.id);
  }

  Future<void> loadMoreStudents() async {
    if (selectedClass.value == null) return;
    if (currentSessionId.value.isNotEmpty) {
      await loadStudentsForSession(reset: false);
    } else {
      await loadStudentsForClass(reset: false);
    }
  }

  // load students for the class
  // Loads students for the currently selected class.
  //
  // This function loads students for the class set in `selectedClass` and
  // initializes their attendance status to 'absent'. It also sets the
  // `isStudentsLoaded` flag.
  //
  // If the `selectedClass` is null, the function returns immediately without
  // performing any action.
  Future<void> loadStudentsForClass({bool reset = true}) async {
    try {
      if (selectedClass.value == null) {
        //printnt('No class selected, returning');
        return;
      }

      //printnt('Loading students for class: ${selectedClass.value!.id}');
      if (reset) {
        isLoading.value = true;
        _studentsOffset = 0;
        hasMoreStudents.value = true;
      } else {
        if (isLoading.value ||
            isLoadingMoreStudents.value ||
            !hasMoreStudents.value) {
          return;
        }
        isLoadingMoreStudents.value = true;
      }

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClass.value!.id,
        limit: _studentsPageSize,
        offset: _studentsOffset,
      );

      //printnt('Loaded ${classStudents.length} students');

      // Initialize attendance status for all students
      for (var student in classStudents) {
        student.attendanceStatus = 'absent'; // Default status
      }

      if (reset) {
        students.assignAll(classStudents);
      } else {
        students.addAll(classStudents);
      }
      _studentsOffset = students.length;
      hasMoreStudents.value = classStudents.length == _studentsPageSize;
      isStudentsLoaded.value = true;
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      //printnt('Error loading students: $e');
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMoreStudents.value = false;
      }
    }
  }

  // Load students for the current session
  // Loads students for the currently selected session.
  //
  // This function retrieves the list of students for the class associated
  // with the currently selected session, and it attempts to load existing
  // attendance records for these students. If attendance records exist, it
  // updates each student's attendance status accordingly; otherwise, it
  // defaults the status to 'absent'. The `isStudentsLoaded` flag is set upon
  // successful loading of students.
  //
  // If no session is selected or if no class is associated with the selected
  // session, the function returns immediately without performing any action.

  Future<void> loadStudentsForSession({bool reset = true}) async {
    try {
      if (currentSessionId.value.isEmpty || selectedClass.value == null) {
        //printnt('No session or class selected, returning');
        return;
      }

      //printnt('Loading students for session: ${currentSessionId.value}');
      if (reset) {
        isLoading.value = true;
        _studentsOffset = 0;
        hasMoreStudents.value = true;
      } else {
        if (isLoading.value ||
            isLoadingMoreStudents.value ||
            !hasMoreStudents.value) {
          return;
        }
        isLoadingMoreStudents.value = true;
      }

      // Load students for the class
      final classStudents = await studentService.getStudentsForClass(
        selectedClass.value!.id,
        limit: _studentsPageSize,
        offset: _studentsOffset,
      );

      //printnt('Loaded ${classStudents.length} students');

      // Load existing attendance records for this session for the current page of students
      final studentIds = classStudents.map((s) => s.id).toList();
      final attendanceRecords = await attendanceService
          .getAttendanceRecordsForStudentsInSession(currentSessionId.value, studentIds);

      //printnt('Loaded ${attendanceRecords.length} attendance records');

      // Map attendance records to students
      for (var student in classStudents) {
        final record = attendanceRecords.firstWhereOrNull(
          (record) => record.studentId == student.id,
        );

        student.attendanceStatus = record?.status ?? 'absent';
      }

      if (reset) {
        students.assignAll(classStudents);
      } else {
        students.addAll(classStudents);
      }
      _studentsOffset = students.length;
      hasMoreStudents.value = classStudents.length == _studentsPageSize;
      isStudentsLoaded.value = true;
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      //printnt('Error loading students for session: $e');
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMoreStudents.value = false;
      }
    }
  }

  // a student's attendance status
  // Updates the attendance status of a student.
  //
  // This function finds the student in the list by their ID and updates
  // their attendance status with the provided status. If the student is
  // found, the list is refreshed to reflect the change.
  //
  // [studentId] The ID of the student whose status is to be updated.
  // [status] The new attendance status to assign to the student.

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

  // the submitAttendance method

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
        message: 'Attendance submitted and session closed successfully',
        title: 'Success',
      );
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      }

      // Close the session after submitting attendance
      await attendanceService.closeAttendanceSession(currentSessionId.value);

      // Reload the attendance sessions to reflect the updated status
      if (selectedClass.value != null) {
        await loadAttendanceSessions(selectedClass.value!.id);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      //printnt('Error submitting attendance: $e');
      TSnackBar.showError(
        message: 'Failed to submit attendance: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new attendance session
  // Create a new attendance session for the currently selected class.
  //
  // The session's date is set to the current [sessionDate] and the start
  // and end times are set to the values of [startTimeController] and
  // [endTimeController] respectively. If either of the time controllers is
  // empty, the corresponding time is set to null.
  //
  // The session is created by the currently logged in user, and the session
  // is created with the [selectedClass] as its class.
  //
  // After creating the session, the attendance sessions for the class are
  // reloaded and the dialog is closed with a success message.
  //
  // If there is an error while creating the session, an error message is
  // shown and the dialog is not closed.
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
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      }

      TSnackBar.showSuccess(
        message: 'Attendance session created successfully',
        title: 'Success',
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      //printnt('Error creating attendance session: $e');
      TSnackBar.showError(message: 'Failed to create session: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // this method to check if a session is currently running
  // the isSessionRunning method to check the status column

  // Check if a session is currently running with detailed feedback
  Map<String, dynamic> checkSessionStatus(String sessionId) {
    try {
      // Find the session in the list
      final session =
          attendanceSessions.firstWhereOrNull((s) => s.id == sessionId);
      if (session == null) {
        return {'isValid': false, 'message': 'Session not found'};
      }

      // If the session is explicitly marked as closed
      if (session.status == 'closed') {
        return {'isValid': false, 'message': 'Session is manually closed'};
      }

      final now = DateTime.now();
      final sessionDate = session.date;

      // Check if the session is today (ignoring time)
      final isToday = sessionDate.year == now.year &&
          sessionDate.month == now.month &&
          sessionDate.day == now.day;

      if (!isToday) {
        return {
          'isValid': false,
          'message':
              'Session is for ${DateFormat('MMM d, yyyy').format(sessionDate)}. You can only mark attendance for today\'s sessions.'
        };
      }

      // If there's no specific time, consider it running all day
      if (session.startTime == null ||
          session.startTime!.isEmpty ||
          session.endTime == null ||
          session.endTime!.isEmpty) {
        return {'isValid': true, 'message': 'Session Active'};
      }

      // Parse times
      try {
        final startDateTime = _parseTime(session.startTime!, sessionDate);
        final endDateTime = _parseTime(session.endTime!, sessionDate);

        // Debug logging
        // print('Session Window: $startDateTime to $endDateTime');
        // print('Current Time: $now');

        if (now.isBefore(startDateTime)) {
          return {
            'isValid': false,
            'message':
                'Session has not started yet. Starts at ${session.startTime}'
          };
        }

        if (now.isAfter(endDateTime)) {
          return {
            'isValid': false,
            'message': 'Session has ended. Ended at ${session.endTime}'
          };
        }

        return {'isValid': true, 'message': 'Session Active'};
      } catch (e, stackTrace) {
        Sentry.captureException(e, stackTrace: stackTrace);
        // print('Time parsing error: $e');
        // If parsing fails, allow access but log warning
        return {
          'isValid': true,
          'message': 'Session Active (Time format warning)'
        };
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      // print('Error in checkSessionStatus: $e');
      return {'isValid': false, 'message': 'Error checking session status: $e'};
    }
  }

  // Helper to parse time strings like "10:00 AM" or "14:30"
  DateTime _parseTime(String timeStr, DateTime date) {
    final lowerTime = timeStr.trim().toLowerCase();
    int hour = 0;
    int minute = 0;

    if (lowerTime.contains('am') || lowerTime.contains('pm')) {
      // 12-hour format
      final parts = lowerTime.split(':');
      hour = int.parse(parts[0]);
      final minuteParts = parts[1].split(' ');
      minute = int.parse(minuteParts[0]);
      final ampm = minuteParts[1]; // 'am' or 'pm' because of toLowerCase()

      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;
    } else {
      // 24-hour format
      final parts = lowerTime.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Wrapper for backward compatibility (returns simple boolean)
  bool isSessionRunning(String sessionId) {
    return checkSessionStatus(sessionId)['isValid'] as bool;
  }
}
