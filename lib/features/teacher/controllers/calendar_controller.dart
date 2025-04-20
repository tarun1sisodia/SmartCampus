import 'package:get/get.dart';
import '../../../models/attendance_session_model.dart';
import '../../../models/class_model.dart';
import '../../../services/attendance_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
  final AttendanceService attendanceService = AttendanceService();

  // Calendar related variables
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  final calendarFormat = CalendarFormat.month.obs;

  // Sessions and classes data
  final allSessions = <AttendanceSessionModel>[].obs;
  final filteredSessions = <AttendanceSessionModel>[].obs;
  final userClasses = <ClassModel>[].obs;
  final isLoading = true.obs;
  final activeSessionsCount = 0.obs;

  // Filter options
  final showOnlyMyClasses = false.obs;
  final selectedCourse = Rx<String?>(null);
  final selectedYear = Rx<int?>(null);
  final selectedSection = Rx<String?>(null);
  final showAllSessions = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();

    // Listen to filter changes
    ever(showAllSessions, (_) => applyFilters());
    ever(showOnlyMyClasses, (_) => applyFilters());
    ever(selectedCourse, (_) => applyFilters());
    ever(selectedYear, (_) => applyFilters());
    ever(selectedSection, (_) => applyFilters());
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      print('Loading calendar data...');

      // Load all sessions and user's classes in parallel
      final results = await Future.wait([
        attendanceService.getAllAttendanceSessions(),
        attendanceService.getTeacherClasses(),
      ]);

      allSessions.value = results[0] as List<AttendanceSessionModel>;
      userClasses.value = results[1] as List<ClassModel>;

      print(
          'Loaded ${allSessions.length} sessions and ${userClasses.length} classes');

      // Sample the first session to check data
      if (allSessions.isNotEmpty) {
        final sample = allSessions.first;
        print(
            'Sample session - ID: ${sample.id}, Subject: ${sample.subjectName}, Course: ${sample.courseName}');
      }

      // Count active sessions (sessions happening today)
      _updateActiveSessionsCount();
      print('Active sessions count: ${activeSessionsCount.value}');

      // Apply initial filters
      applyFilters();
      print('Applied filters, filtered sessions: ${filteredSessions.length}');
    } catch (e) {
      print('Error loading calendar data: $e');
      TSnackBar.showError(
        message: 'Failed to load calendar data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateActiveSessionsCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    activeSessionsCount.value = allSessions.where((session) {
      // Check if session is today
      final sessionDate =
          DateTime(session.date.year, session.date.month, session.date.day);

      if (sessionDate != today) return false;

      // Check if session is currently active
      if (session.startTime == null || session.endTime == null) return false;

      try {
        // Parse time in format "06 AM" or "07 PM"
        int startHour = 0;
        int startMinute = 0;
        int endHour = 0;
        int endMinute = 0;

        // Parse start time
        final startTimeParts = session.startTime!.split(' ');
        if (startTimeParts.length == 2) {
          final timePart = startTimeParts[0];
          final amPm = startTimeParts[1].toUpperCase();

          if (timePart.contains(':')) {
            final parts = timePart.split(':');
            startHour = int.parse(parts[0]);
            startMinute = int.parse(parts[1]);
          } else {
            startHour = int.parse(timePart);
            startMinute = 0;
          }

          // Convert to 24-hour format
          if (amPm == 'PM' && startHour < 12) {
            startHour += 12;
          } else if (amPm == 'AM' && startHour == 12) {
            startHour = 0;
          }
        }

        // Parse end time
        final endTimeParts = session.endTime!.split(' ');
        if (endTimeParts.length == 2) {
          final timePart = endTimeParts[0];
          final amPm = endTimeParts[1].toUpperCase();

          if (timePart.contains(':')) {
            final parts = timePart.split(':');
            endHour = int.parse(parts[0]);
            endMinute = int.parse(parts[1]);
          } else {
            endHour = int.parse(timePart);
            endMinute = 0;
          }

          // Convert to 24-hour format
          if (amPm == 'PM' && endHour < 12) {
            endHour += 12;
          } else if (amPm == 'AM' && endHour == 12) {
            endHour = 0;
          }
        }

        final sessionStart = DateTime(
            today.year, today.month, today.day, startHour, startMinute);
        final sessionEnd =
            DateTime(today.year, today.month, today.day, endHour, endMinute);

        return now.isAfter(sessionStart) && now.isBefore(sessionEnd);
      } catch (e) {
        print('Error parsing session times: $e');
        return false;
      }
    }).length;
  }

  void applyFilters() {
    List<AttendanceSessionModel> result = List.from(allSessions);

    // If not showing all sessions, apply filters
    if (!showAllSessions.value) {
      // Filter by teacher's classes if selected
      if (showOnlyMyClasses.value) {
        final userClassIds = userClasses.map((c) => c.id).toSet();
        result = result
            .where((session) => userClassIds.contains(session.classId))
            .toList();
      }

      // Apply course filter
      if (selectedCourse.value != null) {
        result = result
            .where((session) => session.courseName == selectedCourse.value)
            .toList();
      }

      // Apply year filter
      if (selectedYear.value != null) {
        result = result
            .where((session) => session.year == selectedYear.value)
            .toList();
      }

      // Apply section filter
      if (selectedSection.value != null) {
        result = result
            .where((session) => session.section == selectedSection.value)
            .toList();
      }
    }

    filteredSessions.value = result;
  }

  List<AttendanceSessionModel> getSessionsForDay(DateTime day) {
    return filteredSessions.where((session) {
      return session.date.year == day.year &&
          session.date.month == day.month &&
          session.date.day == day.day;
    }).toList();
  }

  bool isSessionActive(AttendanceSessionModel session) {
    if (session.startTime == null || session.endTime == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate =
        DateTime(session.date.year, session.date.month, session.date.day);

    // If not today, it's not active
    if (sessionDate != today) return false;

    try {
      // Parse time in format "06 AM" or "07 PM"
      int startHour = 0;
      int startMinute = 0;
      int endHour = 0;
      int endMinute = 0;

      // Parse start time
      final startTimeParts = session.startTime!.split(' ');
      if (startTimeParts.length == 2) {
        final timePart = startTimeParts[0];
        final amPm = startTimeParts[1].toUpperCase();

        if (timePart.contains(':')) {
          final parts = timePart.split(':');
          startHour = int.parse(parts[0]);
          startMinute = int.parse(parts[1]);
        } else {
          startHour = int.parse(timePart);
          startMinute = 0;
        }

        // Convert to 24-hour format
        if (amPm == 'PM' && startHour < 12) {
          startHour += 12;
        } else if (amPm == 'AM' && startHour == 12) {
          startHour = 0;
        }
      }

      // Parse end time
      final endTimeParts = session.endTime!.split(' ');
      if (endTimeParts.length == 2) {
        final timePart = endTimeParts[0];
        final amPm = endTimeParts[1].toUpperCase();

        if (timePart.contains(':')) {
          final parts = timePart.split(':');
          endHour = int.parse(parts[0]);
          endMinute = int.parse(parts[1]);
        } else {
          endHour = int.parse(timePart);
          endMinute = 0;
        }

        // Convert to 24-hour format
        if (amPm == 'PM' && endHour < 12) {
          endHour += 12;
        } else if (amPm == 'AM' && endHour == 12) {
          endHour = 0;
        }
      }

      final sessionStart =
          DateTime(today.year, today.month, today.day, startHour, startMinute);
      final sessionEnd =
          DateTime(today.year, today.month, today.day, endHour, endMinute);

      return now.isAfter(sessionStart) && now.isBefore(sessionEnd);
    } catch (e) {
      print('Error parsing session times: $e');
      return false;
    }
  }

  // Get unique course names from user classes
  List<String> get availableCourses {
    return userClasses
        .map((c) => c.courseName)
        .where((name) => name != null)
        .map((name) => name!)
        .toSet()
        .toList();
  }

  // Get unique years from user classes
  List<int> get availableYears {
    return userClasses.map((c) => c.year).toSet().toList();
  }

  // Get unique sections from user classes
  List<String> get availableSections {
    return userClasses
        .map((c) => c.section)
        .where((section) => section != null)
        .map((section) => section!)
        .toSet()
        .toList();
  }

  void refreshData() {
    loadData();
  }
}
