import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../models/attendance_session_model.dart';
import '../../../services/class_service.dart';
import '../../../services/attendance_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import 'attendance_controller.dart';

class AllSessionsController extends GetxController {
  final attendanceService = AttendanceService();
  final classService = ClassService();
  // final attendanceController = Get.put(AttendanceController());
  late final AttendanceController attendanceController;

  final isLoading = false.obs;
  final allSessions = <AttendanceSessionWithClass>[].obs;
  final filteredSessions = <AttendanceSessionWithClass>[].obs;
  final classes = <ClassModel>[].obs;

  // Filter variables
  final searchController = TextEditingController();
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final selectedClassIds = <String>[].obs;

  // New properties for multi-select
  final isSelectionMode = false.obs;
  final selectedSessionIds = <String>{}.obs;
  final isAllSelected = false.obs;

  @override
  void onInit() {
    super.onInit();
    ////print('AllSessionsController initialized');

    // Initialize the attendanceController here
    if (Get.isRegistered<AttendanceController>()) {
      attendanceController = Get.find<AttendanceController>();
    } else {
      attendanceController = Get.put(AttendanceController());
    }

    loadAllSessions();
    loadClasses();
  }

  @override
  void onClose() {
    ////print('AllSessionsController disposed');
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadAllSessions() async {
    try {
      ////print('Loading all sessions...');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        ////print('No user logged in');
        TSnackBar.showError(message: 'You must be logged in to view sessions');
        return;
      }

      ////print('Fetching classes for teacher: ${currentUser.id}');
      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );

      List<AttendanceSessionWithClass> allTeacherSessions = [];

      for (var classModel in teacherClasses) {
        ////print('Fetching sessions for class: ${classModel.id}');
        final sessions = await attendanceService.getAttendanceSessions(
          classModel.id,
        );

        final sessionsWithClass = sessions.map((session) {
          ////print('Processing session: ${session.id}');
          return AttendanceSessionWithClass(
            id: session.id,
            classId: session.classId,
            date: session.date,
            startTime: session.startTime,
            endTime: session.endTime,
            createdBy: session.createdBy,
            createdAt: session.createdAt,
            className: classModel.courseName,
            subjectName: classModel.subjectName,
            classModel: classModel,
          );
        }).toList();

        allTeacherSessions.addAll(sessionsWithClass);
      }

      allTeacherSessions.sort((a, b) => b.date.compareTo(a.date));

      ////print('All sessions loaded: ${allTeacherSessions.length}');
      allSessions.assignAll(allTeacherSessions);
      filteredSessions.assignAll(allTeacherSessions);
    } catch (e) {
      ////print('Error loading sessions: $e');
      TSnackBar.showError(message: 'Failed to load sessions: ${e.toString()}');
    } finally {
      isLoading.value = false;
      ////print('Finished loading sessions');
    }
  }

  Future<void> loadClasses() async {
    try {
      ////print('Loading classes...');
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        ////print('No user logged in');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );
      ////print('Classes loaded: ${teacherClasses.length}');
      classes.assignAll(teacherClasses);
    } catch (e) {
      ////print('Error loading classes: $e');
    }
  }

  void filterSessions() {
    ////print('Filtering sessions...');
    final searchTerm = searchController.text.toLowerCase();

    filteredSessions.value = allSessions.where((session) {
      final isInDateRange = session.date.isAfter(
            startDate.value.subtract(const Duration(days: 1)),
          ) &&
          session.date.isBefore(endDate.value.add(const Duration(days: 1)));

      final isClassSelected = selectedClassIds.isEmpty ||
          selectedClassIds.contains(session.classId);

      final matchesSearch = searchTerm.isEmpty ||
          (session.className?.toLowerCase().contains(searchTerm) ?? false) ||
          (session.subjectName?.toLowerCase().contains(searchTerm) ?? false);

      return isInDateRange && isClassSelected && matchesSearch;
    }).toList();

    ////print('Filtered sessions count: ${filteredSessions.length}');
  }

  void resetFilters() {
    ////print('Resetting filters...');
    searchController.clear();
    startDate.value = DateTime.now().subtract(const Duration(days: 30));
    endDate.value = DateTime.now();
    selectedClassIds.clear();
    filteredSessions.assignAll(allSessions);
    ////print('Filters reset');
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      ////print('Deleting session: $sessionId');
      isLoading.value = true;

      await attendanceService.deleteSession(sessionId);

      allSessions.removeWhere((session) => session.id == sessionId);
      filteredSessions.removeWhere((session) => session.id == sessionId);

      ////print('Session deleted: $sessionId');
      TSnackBar.showSuccess(
        message: 'Session deleted successfully',
        title: 'Success',
      );
    } catch (e) {
      ////print('Error deleting session: $e');
      TSnackBar.showError(message: 'Failed to delete session: ${e.toString()}');
    } finally {
      isLoading.value = false;
      ////print('Finished deleting session');
    }
  }

// Add this method to check if a session is closed
  bool isSessionClosed(AttendanceSessionWithClass session) {
    // Consider a session closed if its status is explicitly 'closed'
    if (session.status == 'closed') return true;

    // Also check if closedAt timestamp exists
    if (session.closedAt != null) return true;

    return false;
  }

// Modify the isSessionRunning method to also check if the session is closed
  bool isSessionRunning(AttendanceSessionWithClass session) {
    try {
      // First check if the session is closed
      if (isSessionClosed(session)) return false;

      final now = DateTime.now();
      final sessionDate = session.date;

      // Check if the session is today
      if (sessionDate.year == now.year &&
          sessionDate.month == now.month &&
          sessionDate.day == now.day) {
        // If there's no specific time, consider it running all day
        if (session.startTime == null || session.endTime == null) {
          return true;
        }

        // Parse the time strings with AM/PM format
        DateTime? sessionStart;
        DateTime? sessionEnd;

        // Try to parse different time formats
        try {
          // First try format like "10:00 AM"
          final startDateTime = DateFormat("h:mm a").parse(session.startTime!);
          final endDateTime = DateFormat("h:mm a").parse(session.endTime!);

          sessionStart = DateTime(now.year, now.month, now.day,
              startDateTime.hour, startDateTime.minute);

          sessionEnd = DateTime(now.year, now.month, now.day, endDateTime.hour,
              endDateTime.minute);
        } catch (e) {
          // If that fails, try 24-hour format like "14:30"
          try {
            final startTimeParts = session.startTime!.split(':');
            final endTimeParts = session.endTime!.split(':');

            final startHour = int.parse(startTimeParts[0]);
            final startMinute = int.parse(startTimeParts[1]);

            final endHour = int.parse(endTimeParts[0]);
            final endMinute = int.parse(endTimeParts[1]);

            sessionStart =
                DateTime(now.year, now.month, now.day, startHour, startMinute);
            sessionEnd =
                DateTime(now.year, now.month, now.day, endHour, endMinute);
          } catch (e) {
            ////print('Error parsing session time: $e');
            return false;
          }
        }

        // Check if current time is between start and end
        return now.isAfter(sessionStart) && now.isBefore(sessionEnd);
      }

      return false;
    } catch (e) {
      ////print('Error in isSessionRunning: $e');
      return false;
    }
  }

// Add a method to close a session after attendance submission
  Future<void> closeSession(String sessionId) async {
    try {
      isLoading.value = true;

      // Call the service method to close the session
      await attendanceService.closeAttendanceSession(sessionId);

      // Update the local session data
      final sessionIndex = allSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex >= 0) {
        final updatedSession = allSessions[sessionIndex];
        allSessions[sessionIndex] = AttendanceSessionWithClass(
          id: updatedSession.id,
          classId: updatedSession.classId,
          date: updatedSession.date,
          startTime: updatedSession.startTime,
          endTime: updatedSession.endTime,
          createdBy: updatedSession.createdBy,
          createdAt: updatedSession.createdAt,
          className: updatedSession.className,
          subjectName: updatedSession.subjectName,
          classModel: updatedSession.classModel,
          status: 'closed',
          closedAt: DateTime.now(),
        );
      }

      // Also update in filtered sessions
      final filteredIndex =
          filteredSessions.indexWhere((s) => s.id == sessionId);
      if (filteredIndex >= 0) {
        final updatedSession = filteredSessions[filteredIndex];
        filteredSessions[filteredIndex] = AttendanceSessionWithClass(
          id: updatedSession.id,
          classId: updatedSession.classId,
          date: updatedSession.date,
          startTime: updatedSession.startTime,
          endTime: updatedSession.endTime,
          createdBy: updatedSession.createdBy,
          createdAt: updatedSession.createdAt,
          className: updatedSession.className,
          subjectName: updatedSession.subjectName,
          classModel: updatedSession.classModel,
          status: 'closed',
          closedAt: DateTime.now(),
        );
      }

      TSnackBar.showSuccess(
        message: 'Session closed successfully',
        title: 'Success',
      );
    } catch (e) {
      ////print('Error closing session: $e');
      TSnackBar.showError(message: 'Failed to close session: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  // New methods for multi-select functionality

  void toggleSelectionMode(String? initialSessionId) {
    isSelectionMode.value = !isSelectionMode.value;

    if (!isSelectionMode.value) {
      // Clear selections when exiting selection mode
      clearSelections();
    } else if (initialSessionId != null) {
      // If entering selection mode with an initial selection
      selectedSessionIds.add(initialSessionId);
    }
  }

  void toggleSessionSelection(String sessionId) {
    if (selectedSessionIds.contains(sessionId)) {
      selectedSessionIds.remove(sessionId);
      // If no sessions are selected, exit selection mode
      if (selectedSessionIds.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedSessionIds.add(sessionId);
    }

    // Update "all selected" state
    isAllSelected.value = selectedSessionIds.length == filteredSessions.length;
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      // Deselect all
      selectedSessionIds.clear();
      isSelectionMode.value = false;
    } else {
      // Select all
      selectedSessionIds.clear();
      for (var session in filteredSessions) {
        selectedSessionIds.add(session.id);
      }
    }
    isAllSelected.value = !isAllSelected.value;
  }

  void clearSelections() {
    selectedSessionIds.clear();
    isAllSelected.value = false;
  }

  Future<void> deleteSelectedSessions() async {
    try {
      isLoading.value = true;

      // Create a copy to avoid modification during iteration
      final sessionsToDelete = Set<String>.from(selectedSessionIds);

      for (var sessionId in sessionsToDelete) {
        await attendanceService.deleteSession(sessionId);
      }

      // Remove deleted sessions from lists
      allSessions
          .removeWhere((session) => sessionsToDelete.contains(session.id));
      filteredSessions
          .removeWhere((session) => sessionsToDelete.contains(session.id));

      // Exit selection mode
      isSelectionMode.value = false;
      clearSelections();

      // Show success message
      final count = sessionsToDelete.length;
      TSnackBar.showSuccess(
        message:
            '$count ${count == 1 ? 'session' : 'sessions'} deleted successfully',
        title: 'Success',
      );
    } catch (e) {
      ////print('Error deleting selected sessions: $e');
      TSnackBar.showError(
          message: 'Failed to delete sessions: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}

class AttendanceSessionWithClass extends AttendanceSessionModel {
  final String? className;
  @override
  final String? subjectName;
  final ClassModel? classModel;

  AttendanceSessionWithClass({
    required super.id,
    required super.classId,
    required super.date,
    super.startTime,
    super.endTime,
    required super.createdBy,
    super.createdAt,
    this.className,
    this.subjectName,
    this.classModel,
    super.status,
    super.closedAt,
  });
}
