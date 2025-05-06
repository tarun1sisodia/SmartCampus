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

  @override

  /// Called when the controller is initialized.
  ///
  /// If a session ID is already set, it loads students for the current session.
  /// It then listens to changes in the students list to update statistics and
  /// listens to changes in the session ID to start/stop the timer.
  @override
  void onInit() {
    super.onInit();

    // Ensure the timer updates the UI when the session starts
    ever(isTimerRunning, (_) {
      if (isTimerRunning.value) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });

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

  /// Stops the session timer when the controller is about to be removed from the
  /// widget tree. This is called by the GetX framework when the controller is
  /// about to be removed from the widget tree. It stops the session timer and
  /// calls the superclass's [onClose].
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  /// Initializes the session timer by parsing the start and end times of the
  /// current session from the attendance sessions list. It then starts the timer.
  ///
  /// If the start time is not set, the timer is not started. If the end time is
  /// not set, the timer is not stopped.
  void _initializeSessionTimer() {
    // Get the current session details
    final currentSession =
        attendanceController.attendanceSessions.firstWhereOrNull(
      (session) => session.id == attendanceController.currentSessionId.value,
    );

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
            print(
                'Session start time parsed successfully: ${sessionStartTime.value}');
          } else {
            print('Failed to parse start time: ${currentSession.startTime}');
          }
        } catch (e) {
          print('Error parsing start time: $e');
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
            print(
                'Session end time parsed successfully: ${sessionEndTime.value}');
          } else {
            print('Failed to parse end time: ${currentSession.endTime}');
          }
        } catch (e) {
          print('Error parsing end time: $e');
        }
      }

      // For debugging
      print('Current time: ${DateTime.now()}');
      print('Session date: ${currentSession.date}');
      print('Session start time (raw): ${currentSession.startTime}');
      print('Session end time (raw): ${currentSession.endTime}');
      print('Parsed start time: ${sessionStartTime.value}');
      print('Parsed end time: ${sessionEndTime.value}');

      // Start the timer
      _startTimer();
    }
  }

  /// Starts a periodic timer that updates the elapsed time every second.
  /// Cancels any existing timer before starting a new one. The timer
  /// updates the `elapsedTime` and calls `_updateRemainingTime` to
  /// recalculate the remaining session time. Sets `isTimerRunning` to true
  /// when the timer starts.

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    print('Starting timer with isTimerRunning set to true');
    isTimerRunning.value = true;
    print('isTimerRunning value after setting: ${isTimerRunning.value}');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedTime.value++;
      _updateRemainingTime();
      print(
          'Timer tick: ${elapsedTime.value}, isTimerRunning: ${isTimerRunning.value}');
    });
  }

  /// Stops the current timer and resets all related time-tracking values.
  ///
  /// Cancels the active timer, sets [isTimerRunning] to false, and clears
  /// all time-related state variables, effectively resetting the timer
  /// and session tracking to its initial state.
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
  }

  /// Updates the `remainingTime` based on the current time in relation to the session's start and end times.
  ///
  /// If the session has an end time, it calculates the remaining time until the session ends and updates the
  /// `remainingTime` with the formatted time string. If the remaining time is negative, it sets `remainingTime`
  /// to 'Session Ended'.
  ///
  /// If there is a start time but no end time, it calculates the elapsed time since the session started and
  /// updates `remainingTime` with the elapsed time formatted string.
  ///
  /// If neither start nor end time is available, it shows the time elapsed since the timer started, using
  /// the `elapsedTime` value to update `remainingTime`.

  void _updateRemainingTime() {
    final now = DateTime.now();

    if (sessionEndTime.value != null) {
      // Calculate remaining time until session ends
      final remaining = sessionEndTime.value!.difference(now);

      print('Current time: $now');
      print('Session end time: ${sessionEndTime.value}');
      print('Remaining time in seconds: ${remaining.inSeconds}');

      if (remaining.isNegative) {
        remainingTime.value = 'Session Ended';
        print('Session has ended (negative remaining time)');
      } else {
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes.remainder(60);
        final seconds = remaining.inSeconds.remainder(60);

        remainingTime.value =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        print('Session is active, remaining: ${remainingTime.value}');
      }
    } else if (sessionStartTime.value != null) {
      // If no end time but we have start time, show elapsed time since start
      final elapsed = now.difference(sessionStartTime.value!);

      final hours = elapsed.inHours;
      final minutes = elapsed.inMinutes.remainder(60);
      final seconds = elapsed.inSeconds.remainder(60);

      remainingTime.value =
          'Elapsed: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      print('No end time set, showing elapsed time: ${remainingTime.value}');
    } else {
      // If no start or end time, just show elapsed time since timer started
      final hours = elapsedTime.value ~/ 3600;
      final minutes = (elapsedTime.value ~/ 60) % 60;
      final seconds = elapsedTime.value % 60;

      remainingTime.value =
          'Timer: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      print('No start or end time, showing timer: ${remainingTime.value}');
    }
  }

  // Update attendance statistics
  /// Updates attendance statistics based on the current students and their statuses.
  ///
  /// This function iterates over the list of students in the attendance controller,
  /// counts the number of students with each attendance status, and updates the
  /// `presentCount`, `absentCount`, `lateCount`, and `excusedCount` state variables
  /// accordingly. Additionally, it checks if all students have been marked and
  /// sets the `hasCompletedAttendance` state variable to true if all students have
  /// been marked, false otherwise.
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
  /// Marks the current student with the given attendance status.
  ///
  /// This function uses the attendance controller to update the attendance status
  /// of the student at the current index. After updating the student's status, it
  /// calls the [updateStatistics] function to update the attendance statistics.
  ///
  /// If the current index is at or past the end of the list of students,
  /// this function does nothing.
  void markCurrentStudent(String status) {
    if (currentIndex.value < attendanceController.students.length) {
      final student = attendanceController.students[currentIndex.value];
      attendanceController.updateStudentStatus(student.id, status);
      updateStatistics();
    }
  }

  // Move to next student
  /// Advances to the next student in the attendance list.
  ///
  /// This function increments the `currentIndex` to point to the next student,
  /// if the current index is not at the last student in the list. If the
  /// `currentIndex` is already at the last student and all students have been
  /// marked, it shows a completion message indicating that attendance for all
  /// students has been completed.

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
  /// Moves to the previous student in the attendance list.
  ///
  /// This function decrements the `currentIndex` to point to the previous student,
  /// if the current index is not at the first student in the list.
  void moveToPreviousStudent() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  // Submit attendance
  /// Submits attendance for all students in the current class.
  ///
  /// This function will first set `isSubmitting` to `true` to indicate that the
  /// submission is in progress. It will then call the `submitAttendance` method
  /// on the `AttendanceController` to submit the attendance records to the
  /// server. If the submission is successful, it will return to the previous
  /// screen by calling `Get.back()`. If an error occurs, it will show an error
  /// message using `TSnackBar.showError` and log the error to the console.
  /// Finally, it will set `isSubmitting` to `false` to indicate that the
  /// submission is complete.
  Future<void> submitAttendance() async {
    try {
      isSubmitting.value = true;
      await attendanceController.submitAttendance();
      Get.offNamed(
          '/attendance-reports'); // Return to previous screen after submission
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
