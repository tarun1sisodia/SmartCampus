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
  
  @override
  void onInit() {
    super.onInit();
    loadData();
    
    // Listen to filter changes
    ever(showOnlyMyClasses, (_) => applyFilters());
    ever(selectedCourse, (_) => applyFilters());
    ever(selectedYear, (_) => applyFilters());
    ever(selectedSection, (_) => applyFilters());
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load all sessions and user's classes in parallel
      final results = await Future.wait([
        attendanceService.getAllAttendanceSessions(),
        attendanceService.getTeacherClasses(),
      ]);
      
      allSessions.value = results[0] as List<AttendanceSessionModel>;
      userClasses.value = results[1] as List<ClassModel>;
      
      // Count active sessions (sessions happening today)
       // Count active sessions (sessions happening today)
      _updateActiveSessionsCount();

      // Apply initial filters
      applyFilters();
    } catch (e) {
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
        final startTimeParts = session.startTime!.split(':');
        final endTimeParts = session.endTime!.split(':');

        final startHour = int.parse(startTimeParts[0]);
        final startMinute = int.parse(startTimeParts[1]);
        final endHour = int.parse(endTimeParts[0]);
        final endMinute = int.parse(endTimeParts[1]);

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

    // Filter by teacher's classes if selected
    if (showOnlyMyClasses.value) {
      final userClassIds = userClasses.map((c) => c.id).toSet();
      result = result
          .where((session) => userClassIds.contains(session.classId))
          .toList();
    }

    // Apply course filter
    if (selectedCourse.value != null) {
      final filteredClassIds = userClasses
          .where((c) => c.courseName == selectedCourse.value)
          .map((c) => c.id)
          .toSet();

      result = result
          .where((session) => filteredClassIds.contains(session.classId))
          .toList();
    }

    // Apply year filter
    if (selectedYear.value != null) {
      final filteredClassIds = userClasses
          .where((c) => c.year == selectedYear.value)
          .map((c) => c.id)
          .toSet();

      result = result
          .where((session) => filteredClassIds.contains(session.classId))
          .toList();
    }

    // Apply section filter
    if (selectedSection.value != null) {
      final filteredClassIds = userClasses
          .where((c) => c.section == selectedSection.value)
          .map((c) => c.id)
          .toSet();

      result = result
          .where((session) => filteredClassIds.contains(session.classId))
          .toList();
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
      final startTimeParts = session.startTime!.split(':');
      final endTimeParts = session.endTime!.split(':');

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

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
