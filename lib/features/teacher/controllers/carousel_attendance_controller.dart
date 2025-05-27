import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../models/student_model.dart';
import '../../../services/attendance_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import 'attendance_controller.dart';

class CarouselAttendanceController extends GetxController {
  final AttendanceController attendanceController =
      Get.find<AttendanceController>();
  final attendanceService = AttendanceService();

  // Carousel related variables
  final currentIndex = 0.obs;
  final isSubmitting = false.obs;
  final hasCompletedAttendance = false.obs;

  // Statistics
  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;
  final excusedCount = 0.obs;

  // Timer related variables
  final elapsedTime = 0.obs; // in seconds
  final isTimerRunning = false.obs;
  Timer? _timer;
  final sessionStartTime = Rx<DateTime?>(null);
  final sessionEndTime = Rx<DateTime?>(null);
  final remainingTime = ''.obs;
  final isCountdownMode =
      false.obs; // Track if we're in countdown or elapsed mode

  @override
  void onInit() {
    super.onInit();

    // Listen to changes in the students list to update statistics
    ever(attendanceController.students, (_) => updateStatistics());

    // Listen to changes in session ID to start/stop timer
    ever(attendanceController.currentSessionId, (_) {
      if (attendanceController.currentSessionId.value.isNotEmpty) {
        _initializeSessionTimer();
      } else {
        _stopTimer();
      }
    });

    // Delay loading students until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load students for the current session if a session ID is already set
      if (attendanceController.currentSessionId.value.isNotEmpty) {
        attendanceController.loadStudentsForSession();
        _initializeSessionTimer();
      }
    });
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  void _initializeSessionTimer() {
    // Get the current session details
    final currentSession =
        attendanceController.attendanceSessions.firstWhereOrNull(
      (session) => session.id == attendanceController.currentSessionId.value,
    );

    // Reset timer state
    sessionStartTime.value = null;
    sessionEndTime.value = null;
    isCountdownMode.value = false;

    if (currentSession != null) {
      // Parse start and end times
      if (currentSession.startTime != null &&
          currentSession.startTime!.isNotEmpty) {
        try {
          // Try different time formats
          DateTime? parsedStartTime;

          // First try to parse as "HH:mm" (24-hour format)
          if (currentSession.startTime!.contains(':')) {
            final startTimeParts = currentSession.startTime!.split(':');
            if (startTimeParts.length >= 2) {
              final hour = int.tryParse(startTimeParts[0]) ?? 0;
              final minute = int.tryParse(startTimeParts[1].split(' ')[0]) ?? 0;

              // Check if AM/PM is specified
              bool isPM =
                  currentSession.startTime!.toLowerCase().contains('pm');
              bool isAM =
                  currentSession.startTime!.toLowerCase().contains('am');

              int adjustedHour = hour;
              // Convert 12-hour format to 24-hour if needed
              if (isPM && hour < 12) {
                adjustedHour += 12;
              } else if (isAM && hour == 12) {
                adjustedHour = 0;
              }

              parsedStartTime = DateTime(
                currentSession.date.year,
                currentSession.date.month,
                currentSession.date.day,
                adjustedHour,
                minute,
              );
            }
          }

          if (parsedStartTime != null) {
            sessionStartTime.value = parsedStartTime;
          }
        } catch (e) {
          Get.snackbar(
              'Error Parsing Start time', 'Carousel Attendance Controller');
          // print('Error parsing start time: $e');
        }
      }

      if (currentSession.endTime != null &&
          currentSession.endTime!.isNotEmpty) {
        try {
          // Try different time formats
          DateTime? parsedEndTime;

          // First try to parse as "HH:mm" (24-hour format)
          if (currentSession.endTime!.contains(':')) {
            final endTimeParts = currentSession.endTime!.split(':');
            if (endTimeParts.length >= 2) {
              final hour = int.tryParse(endTimeParts[0]) ?? 0;
              final minute = int.tryParse(endTimeParts[1].split(' ')[0]) ?? 0;

              // Check if AM/PM is specified
              bool isPM = currentSession.endTime!.toLowerCase().contains('pm');
              bool isAM = currentSession.endTime!.toLowerCase().contains('am');

              int adjustedHour = hour;
              // Convert 12-hour format to 24-hour if needed
              if (isPM && hour < 12) {
                adjustedHour += 12;
              } else if (isAM && hour == 12) {
                adjustedHour = 0;
              }

              parsedEndTime = DateTime(
                currentSession.date.year,
                currentSession.date.month,
                currentSession.date.day,
                adjustedHour,
                minute,
              );
            }
          }

          if (parsedEndTime != null) {
            sessionEndTime.value = parsedEndTime;
          }
        } catch (e) {
          Get.snackbar('Error parsing end time:', 'The Code');
          // print('Error parsing end time: $e');
        }
      }

      // Determine timer mode based on available time information
      if (sessionEndTime.value != null) {
        isCountdownMode.value =
            true; // Use countdown mode if end time is available
      } else {
        isCountdownMode.value = false; // Use elapsed time mode otherwise
      }

      // Start the timer
      _startTimer();
    }
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    isTimerRunning.value = true;
    elapsedTime.value = 0; // Reset elapsed time counter

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedTime.value++;
      _updateRemainingTime();
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    isTimerRunning.value = false;
    elapsedTime.value = 0;
    sessionStartTime.value = null;
    sessionEndTime.value = null;
    remainingTime.value = '';
    isCountdownMode.value = false;
  }

  void _updateRemainingTime() {
    final now = DateTime.now();

    if (isCountdownMode.value && sessionEndTime.value != null) {
      // COUNTDOWN MODE: Show remaining time until session ends
      final remaining = sessionEndTime.value!.difference(now);

      if (remaining.isNegative) {
        remainingTime.value = 'Session Ended';
      } else {
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes.remainder(60);
        final seconds = remaining.inSeconds.remainder(60);

        remainingTime.value =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    } else {
      // ELAPSED MODE: Show elapsed time since timer started
      final hours = elapsedTime.value ~/ 3600;
      final minutes = (elapsedTime.value ~/ 60) % 60;
      final seconds = elapsedTime.value % 60;

      remainingTime.value =
          'Elapsed: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // attendance statistics
  void updateStatistics() {
    // Count number of students marked as present
    presentCount.value = attendanceController.students
        .where((s) => s.attendanceStatus == 'present')
        .length;

    // Count number of students marked as absent
    absentCount.value = attendanceController.students
        .where((s) => s.attendanceStatus == 'absent')
        .length;

    // Count number of students marked as late
    lateCount.value = attendanceController.students
        .where((s) => s.attendanceStatus == 'late')
        .length;

    // Count number of students marked as excused
    excusedCount.value = attendanceController.students
        .where((s) => s.attendanceStatus == 'excused')
        .length;

    // Check if all students have been marked
    hasCompletedAttendance.value = attendanceController.students.every(
      (s) => s.attendanceStatus != null,
    );
  }

  // Mark attendance for current student
  void markCurrentStudent(String status) {
    if (currentIndex.value < attendanceController.students.length) {
      final student = attendanceController.students[currentIndex.value];
      attendanceController.updateStudentStatus(student.id, status);
      updateStatistics();
    }
  }

  // Move to next student
  void moveToNextStudent() {
    if (currentIndex.value < attendanceController.students.length - 1) {
      currentIndex.value++;
    } else {
      // If we're at the last student, show completion message
      if (hasCompletedAttendance.value) {
        TSnackBar.showSuccess(
          message: 'All students have been marked!',
          title: 'Completed',
        );
      }
    }
  }

  // Move to previous student
  void moveToPreviousStudent() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  // Submit attendance
  Future<void> submitAttendance() async {
    try {
      isSubmitting.value = true;
      await attendanceController.submitAttendance();
      //replace the current screen only.. so back can't be performed
      // Get.off(() =>AttendanceReportsScreen()); // Return to previous screen after submission
      Get.offNamed('/attendance-reports'); // Navigate to attendance reports screen
    } catch (e) {
      TSnackBar.showError(
        message: 'Failed to submit attendance: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Get the current student
  StudentModel? get currentStudent {
    if (attendanceController.students.isEmpty ||
        currentIndex.value >= attendanceController.students.length) {
      return null;
    }
    return attendanceController.students[currentIndex.value];
  }

  // Check if we're on the last student
  bool get isLastStudent {
    return currentIndex.value == attendanceController.students.length - 1;
  }

  // Check if we're on the first student
  bool get isFirstStudent {
    return currentIndex.value == 0;
  }

  // Get completion percentage
  double get completionPercentage {
    if (attendanceController.students.isEmpty) return 0.0;

    int markedCount = attendanceController.students
        .where((s) => s.attendanceStatus != null)
        .length;

    return markedCount / attendanceController.students.length;
  }
}
