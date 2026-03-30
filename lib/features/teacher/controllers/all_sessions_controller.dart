import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../models/class_model.dart';
import '../../../models/attendance_session_model.dart';
import '../../../services/class_service.dart';
import '../../../services/attendance_service.dart';
import '../../../services/realtime_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import 'attendance_controller.dart';
import 'dart:async';

class AllSessionsController extends GetxController {
  final attendanceService = AttendanceService();
  final classService = ClassService();
  late final AttendanceController attendanceController;
  late final RealtimeService realtimeService;

  final isLoading = false.obs;
  final allSessions = <AttendanceSessionWithClass>[].obs;
  final filteredSessions = <AttendanceSessionWithClass>[].obs;
  final classes = <ClassModel>[].obs;

  // Filter variables
  final searchController = TextEditingController();
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final selectedClassIds = <String>[].obs;

  final isSelectionMode = false.obs;
  final selectedSessionIds = <String>{}.obs;
  final isAllSelected = false.obs;

  // Pagination
  final hasMoreSessions = true.obs;
  final isLoadingMore = false.obs;
  static const int _pageSize = 20;
  int _offset = 0;
  final scrollController = ScrollController();

  // Real-time connection status
  final isRealtimeConnected = false.obs;
  final lastUpdated = DateTime.now().obs;

  // Stream subscriptions
  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    debugPrint('AllSessionsController initialized');

    // Initialize the attendanceController here
    if (Get.isRegistered<AttendanceController>()) {
      attendanceController = Get.find<AttendanceController>();
    } else {
      attendanceController = Get.put(AttendanceController());
    }

    _initializeRealtimeService();
    loadAllSessions();
    loadClasses();
  }

  @override
  void onClose() {
    debugPrint('AllSessionsController disposed');
    searchController.dispose();
    scrollController.dispose();

    // Cancel all stream subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.onClose();
  }

  // Initialize real-time service and set up subscriptions
  void _initializeRealtimeService() {
    try {
      // Try to find existing service or create new one
      if (Get.isRegistered<RealtimeService>()) {
        realtimeService = Get.find<RealtimeService>();
      } else {
        realtimeService = Get.put(RealtimeService());
      }

      _setupRealtimeSubscriptions();
      debugPrint('Real-time service initialized for AllSessionsController');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error initializing real-time service: $e');
    }
  }

  // Set up real-time subscriptions
  void _setupRealtimeSubscriptions() {
    try {
      // Subscribe to attendance sessions stream
      final attendanceSessionsSubscription =
          realtimeService.attendanceStream.listen(
        (sessions) {
          debugPrint(
              'Real-time attendance sessions update received: ${sessions.length} sessions');
          _handleAttendanceSessionsUpdate(sessions);
        },
        onError: (error) {
          debugPrint('Error in attendance sessions stream: $error');
          isRealtimeConnected.value = false;
        },
      );

      // Subscribe to classes stream
      final classesSubscription = realtimeService.classesStream.listen(
        (classesData) {
          debugPrint(
              'Real-time classes update received: ${classesData.length} classes');
          _handleClassesUpdate(classesData);
        },
        onError: (error) {
          debugPrint('Error in classes stream: $error');
          isRealtimeConnected.value = false;
        },
      );

      // Subscribe to connection status
      final connectionSubscription = realtimeService.isConnected.listen(
        (connected) {
          debugPrint('Real-time connection status changed: $connected');
          isRealtimeConnected.value = connected;

          if (connected) {
            lastUpdated.value = DateTime.now();
            // Refresh data when reconnected
            loadAllSessions();
            loadClasses();
          }
        },
      );

      _subscriptions.addAll([
        attendanceSessionsSubscription,
        classesSubscription,
        connectionSubscription,
      ]);

      isRealtimeConnected.value = realtimeService.isConnected.value;
      debugPrint('Real-time subscriptions set up successfully');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error setting up real-time subscriptions: $e');
      isRealtimeConnected.value = false;
    }
  }

  // Handle real-time attendance sessions updates
  void _handleAttendanceSessionsUpdate(
      List<Map<String, dynamic>> sessionsData) {
    try {
      debugPrint('Processing attendance sessions update...');

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Convert the raw data to AttendanceSessionWithClass objects
      // Note: This assumes the sessions data includes class information
      // You might need to cross-reference with classes data

      lastUpdated.value = DateTime.now();

      // Trigger a refresh of sessions data
      loadAllSessions();

      debugPrint('Attendance sessions updated successfully');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error handling attendance sessions update: $e');
    }
  }

  // Handle real-time classes updates
  void _handleClassesUpdate(List<Map<String, dynamic>> classesData) {
    try {
      debugPrint('Processing classes update...');

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Filter classes for current teacher
      final teacherClasses = classesData.where((classData) {
        return classData['teacher_id'] == currentUser.id;
      }).toList();

      // Convert to ClassModel objects
      final updatedClasses = teacherClasses.map((classData) {
        final subjectData =
            classData['subjects'] as Map<String, dynamic>? ?? {};
        final courseData = classData['courses'] as Map<String, dynamic>? ?? {};

        return ClassModel(
          id: classData['id'],
          teacherId: classData['teacher_id'],
          subjectId: classData['subject_id'],
          courseId: classData['course_id'],
          semester: classData['semester'],
          section: classData['section'],
          subjectName: subjectData['name'],
          courseName: courseData['name'],
          createdAt: classData['created_at'] != null
              ? DateTime.parse(classData['created_at'])
              : null,
          updatedAt: classData['updated_at'] != null
              ? DateTime.parse(classData['updated_at'])
              : null,
        );
      }).toList();

      classes.assignAll(updatedClasses);
      lastUpdated.value = DateTime.now();

      debugPrint('Classes updated successfully: ${updatedClasses.length} classes');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error handling classes update: $e');
    }
  }

  Future<void> loadAllSessions({bool reset = true}) async {
    try {
      if (reset) {
        debugPrint('Loading all sessions (Reset)...');
        isLoading.value = true;
        _offset = 0;
        hasMoreSessions.value = true;
        allSessions.clear();
      } else {
        if (isLoading.value || isLoadingMore.value || !hasMoreSessions.value) return;
        debugPrint('Loading more sessions (Offset: $_offset)...');
        isLoadingMore.value = true;
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('No user logged in');
        TSnackBar.showError(message: 'You must be logged in to view sessions');
        return;
      }

      // Ensure classes are loaded first for mapping
      if (classes.isEmpty) {
        await loadClasses();
      }

      // Create a map for quick class lookup
      final classMap = {for (var c in classes) c.id: c};

      final sessions = await attendanceService.getSessionsForTeacher(
        teacherId: currentUser.id,
        limit: _pageSize,
        offset: _offset,
      );

      final List<AttendanceSessionWithClass> mappedSessions = sessions.map((session) {
        final classModel = classMap[session.classId];
        
        return AttendanceSessionWithClass(
          id: session.id,
          classId: session.classId,
          date: session.date,
          startTime: session.startTime,
          endTime: session.endTime,
          createdBy: session.createdBy,
          createdAt: session.createdAt,
          // Fallback to session fields if classModel is not found
          className: classModel?.courseName ?? session.courseName,
          subjectName: classModel?.subjectName ?? session.subjectName,
          classModel: classModel ?? ClassModel(
            id: session.classId,
            teacherId: currentUser.id,
            subjectId: '',
            courseId: '',
            semester: session.semester ?? 0,
            section: session.section,
          ),
          status: session.status,
          closedAt: session.closedAt,
        );
      }).toList();

      if (reset) {
        allSessions.assignAll(mappedSessions);
      } else {
        allSessions.addAll(mappedSessions);
      }

      _offset = allSessions.length;
      hasMoreSessions.value = sessions.length == _pageSize;
      
      // Initial filter apply
      filterSessions();
      lastUpdated.value = DateTime.now();
      
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading sessions: $e');
      TSnackBar.showError(message: 'Failed to load sessions: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      debugPrint('Finished loading sessions');
    }
  }

  Future<void> loadMoreSessions() async {
    await loadAllSessions(reset: false);
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreSessions();
    }
  }

  Future<void> loadClasses() async {
    try {
      debugPrint('Loading classes...');
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('No user logged in');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );

      debugPrint('Classes loaded: ${teacherClasses.length}');
      classes.assignAll(teacherClasses);
      lastUpdated.value = DateTime.now();
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading classes: $e');
    }
  }

  void filterSessions() {
    debugPrint('Filtering sessions...');
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

    debugPrint('Filtered sessions count: ${filteredSessions.length}');
  }

  void resetFilters() {
    debugPrint('Resetting filters...');
    searchController.clear();
    startDate.value = DateTime.now().subtract(const Duration(days: 30));
    endDate.value = DateTime.now();
    selectedClassIds.clear();
    filteredSessions.assignAll(allSessions);
    debugPrint('Filters reset');
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      debugPrint('Deleting session: $sessionId');
      isLoading.value = true;

      await attendanceService.deleteSession(sessionId);

      // Note: Real-time subscription will handle UI updates automatically
      // No need to manually remove from lists here

      debugPrint('Session deleted: $sessionId');
      TSnackBar.showSuccess(
        message: 'Session deleted successfully',
        title: 'Success',
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error deleting session: $e');
      TSnackBar.showError(message: 'Failed to delete session: ${e.toString()}');
    } finally {
      isLoading.value = false;
      debugPrint('Finished deleting session');
    }
  }

  // Check if a session is closed
  bool isSessionClosed(AttendanceSessionWithClass session) {
    if (session.status == 'closed') return true;
    if (session.closedAt != null) return true;
    return false;
  }

  // Check if session is running
  bool isSessionRunning(AttendanceSessionWithClass session) {
    try {
      if (isSessionClosed(session)) return false;

      final now = DateTime.now();
      final sessionDate = session.date;

      if (sessionDate.year == now.year &&
          sessionDate.month == now.month &&
          sessionDate.day == now.day) {
        if (session.startTime == null || session.endTime == null) {
          return true;
        }

        DateTime? sessionStart;
        DateTime? sessionEnd;

        try {
          final startDateTime = DateFormat("h:mm a").parse(session.startTime!);
          final endDateTime = DateFormat("h:mm a").parse(session.endTime!);

          sessionStart = DateTime(now.year, now.month, now.day,
              startDateTime.hour, startDateTime.minute);

          sessionEnd = DateTime(now.year, now.month, now.day, endDateTime.hour,
              endDateTime.minute);
        } catch (e) {
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
            debugPrint('Error parsing session time: $e');
            return false;
          }
        }

        return now.isAfter(sessionStart) && now.isBefore(sessionEnd);
      }

      return false;
    } catch (e) {
      debugPrint('Error in isSessionRunning: $e');
      return false;
    }
  }

  // Close a session after attendance submission
  Future<void> closeSession(String sessionId) async {
    try {
      isLoading.value = true;

      await attendanceService.closeAttendanceSession(sessionId);

      // Note: Real-time subscription will handle UI updates automatically
      // No need to manually update local session data here

      TSnackBar.showSuccess(
        message: 'Session closed successfully',
        title: 'Success',
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error closing session: $e');
      TSnackBar.showError(message: 'Failed to close session: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Multi-select functionality methods
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

      // Use the optimized batched deletion method
      final sessionsToDelete = selectedSessionIds.toList();
      if (sessionsToDelete.isNotEmpty) {
        await attendanceService.deleteSessions(sessionsToDelete);
      }

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
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error deleting selected sessions: $e');
      TSnackBar.showError(
          message: 'Failed to delete sessions: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Manual refresh method
  Future<void> refreshData() async {
    debugPrint('Manual refresh triggered');
    await Future.wait([
      loadAllSessions(),
      loadClasses(),
    ]);
  }

  // Get real-time connection status
  bool get isConnected => isRealtimeConnected.value;

  // Get last updated time formatted
  String get lastUpdatedFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated.value);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, HH:mm').format(lastUpdated.value);
    }
  }
}

// Model class for sessions with class information
class AttendanceSessionWithClass {
  final String id;
  final String classId;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String? createdBy;
  final DateTime? createdAt;
  final String? className;
  final String? subjectName;
  final ClassModel classModel;
  final String? status;
  final DateTime? closedAt;

  AttendanceSessionWithClass({
    required this.id,
    required this.classId,
    required this.date,
    this.startTime,
    this.endTime,
    required this.createdBy,
    this.createdAt,
    this.className,
    this.subjectName,
    required this.classModel,
    this.status,
    this.closedAt,
  });

  factory AttendanceSessionWithClass.fromAttendanceSession(
    AttendanceSessionModel session,
    ClassModel classModel,
  ) {
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
      status: session.status,
      closedAt: session.closedAt,
    );
  }
}
