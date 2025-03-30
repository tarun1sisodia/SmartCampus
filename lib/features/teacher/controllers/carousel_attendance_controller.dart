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
  void onInit() {
    super.onInit();
    // Load students for the current session if a session ID is already set
    if (attendanceController.currentSessionId.value.isNotEmpty) {
      attendanceController.loadStudentsForSession();
    }
    
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
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  void _initializeSessionTimer() {
    // Get the current session details
    final currentSession = attendanceController.attendanceSessions
        .firstWhereOrNull(
          (session) =>
              session.id == attendanceController.currentSessionId.value,
        );

    if (currentSession != null) {
      // Parse start and end times
      if (currentSession.startTime != null &&
          currentSession.startTime!.isNotEmpty) {
        final startTimeParts = currentSession.startTime!.split(':');
        if (startTimeParts.length >= 2) {
          final hour = int.tryParse(startTimeParts[0]) ?? 0;
          final minute = int.tryParse(startTimeParts[1]) ?? 0;

          final now = DateTime.now();
          sessionStartTime.value = DateTime(
            currentSession.date.year,
            currentSession.date.month,
            currentSession.date.day,
            hour,
            minute,
          );
        }
      }

      if (currentSession.endTime != null &&
          currentSession.endTime!.isNotEmpty) {
        final endTimeParts = currentSession.endTime!.split(':');
        if (endTimeParts.length >= 2) {
          final hour = int.tryParse(endTimeParts[0]) ?? 0;
          final minute = int.tryParse(endTimeParts[1]) ?? 0;

          final now = DateTime.now();
          sessionEndTime.value = DateTime(
            currentSession.date.year,
            currentSession.date.month,
            currentSession.date.day,
            hour,
            minute,
          );
        }
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
  }

  void _updateRemainingTime() {
    if (sessionEndTime.value != null) {
      final now = DateTime.now();
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
      // If no end time, just show elapsed time
      final hours = elapsedTime.value ~/ 3600;
      final minutes = (elapsedTime.value ~/ 60) % 60;
      final seconds = elapsedTime.value % 60;

      remainingTime.value =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Update attendance statistics
  void updateStatistics() {
    presentCount.value =
        attendanceController.students
            .where((s) => s.attendanceStatus == 'present')
            .length;

    absentCount.value =
        attendanceController.students
            .where((s) => s.attendanceStatus == 'absent')
            .length;

    lateCount.value =
        attendanceController.students
            .where((s) => s.attendanceStatus == 'late')
            .length;

    excusedCount.value =
        attendanceController.students
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
      Get.back(); // Return to previous screen after submission
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

    int markedCount =
        attendanceController.students
            .where((s) => s.attendanceStatus != null)
            .length;

    return markedCount / attendanceController.students.length;
  }
}
