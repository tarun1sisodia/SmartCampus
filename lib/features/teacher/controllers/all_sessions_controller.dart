import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final attendanceController = Get.find<AttendanceController>();
  
  final isLoading = false.obs;
  final allSessions = <AttendanceSessionWithClass>[].obs;
  final filteredSessions = <AttendanceSessionWithClass>[].obs;
  final classes = <ClassModel>[].obs;
  
  // Filter variables
  final searchController = TextEditingController();
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final selectedClassIds = <String>[].obs;
  
  @override
  /// Called when the controller is initialized.
  ///
  /// Loads all attendance sessions for all classes taught by the current teacher,
  /// and loads all classes taught by the current teacher.
  void onInit() {
    super.onInit();
    loadAllSessions();
    loadClasses();
  }
  
  @override
  /// Disposes of the search controller and calls the superclass's [onClose].
  ///
  /// This is called when the controller is about to be removed from the widget tree.
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  /// Loads all attendance sessions for classes taught by the current teacher.
  ///
  /// This function is called when the controller is initialized, and also when
  /// the user searches for sessions or changes the date range.
  ///
  Future<void> loadAllSessions() async {
    try {
      isLoading.value = true;
      
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(message: 'You must be logged in to view sessions');
        return;
      }
      
      // Get all classes for this teacher
      final teacherClasses = await classService.getTeacherClasses(currentUser.id);
      
      // Get sessions for all classes
      List<AttendanceSessionWithClass> allTeacherSessions = [];
      
      for (var classModel in teacherClasses) {
        final sessions = await attendanceService.getAttendanceSessions(classModel.id);
        
        // Add class info to each session
        final sessionsWithClass = sessions.map((session) {
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
      
      // Sort sessions by date (newest first)
      allTeacherSessions.sort((a, b) => b.date.compareTo(a.date));
      
      allSessions.assignAll(allTeacherSessions);
      filteredSessions.assignAll(allTeacherSessions);
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load sessions: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Loads all classes taught by the current teacher.
  ///
  /// This function retrieves the classes associated with the currently
  /// authenticated teacher and updates the `classes` observable list
  /// with the fetched data. If the user is not authenticated, the 
  /// function will return early. Any errors encountered during the 
  /// process are caught and logged to the console.

  /// Loads all classes taught by the current teacher.
  ///
  /// If the user is not authenticated, the function will return early.
  /// Any errors encountered during the process are caught and logged to the console.
  ///
  /// This function updates the `classes` observable list with the fetched data.
  Future<void> loadClasses() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;
      
      final teacherClasses = await classService.getTeacherClasses(currentUser.id);
      classes.assignAll(teacherClasses);
    } catch (e) {
      print('Error loading classes: $e');
    }
  }
  
  /// Filters sessions based on search term, date range, and selected classes.
  ///
  /// Applies three filtering criteria to the [allSessions] list:
  /// 1. Date range filter using [startDate] and [endDate]
  /// 2. Class selection filter using [selectedClassIds]
  /// 3. Search term filter matching against class name and subject name
  ///
  /// Updates [filteredSessions] with the filtered list of sessions.
  void filterSessions() {
    final searchTerm = searchController.text.toLowerCase();
    
    filteredSessions.value = allSessions.where((session) {
      // Apply date filter
      final isInDateRange = session.date.isAfter(startDate.value.subtract(const Duration(days: 1))) && 
                           session.date.isBefore(endDate.value.add(const Duration(days: 1)));
      
      // Apply class filter if any classes are selected
      final isClassSelected = selectedClassIds.isEmpty || selectedClassIds.contains(session.classId);
      
      // Apply search filter
      final matchesSearch = searchTerm.isEmpty || 
                           (session.className?.toLowerCase().contains(searchTerm) ?? false) ||
                           (session.subjectName?.toLowerCase().contains(searchTerm) ?? false);
      
      return isInDateRange && isClassSelected && matchesSearch;
    }).toList();
  }
  
  /// Resets all filters to their default values.
  ///
  /// Clears the search term, sets the date range to the last 30 days, and
  /// clears the selected class IDs, resulting in [filteredSessions] being
  /// reset to [allSessions].
  void resetFilters() {
    searchController.clear();
    startDate.value = DateTime.now().subtract(const Duration(days: 30));
    endDate.value = DateTime.now();
    selectedClassIds.clear();
    filteredSessions.assignAll(allSessions);
  }
}

// Extended model to include class information with session
class AttendanceSessionWithClass extends AttendanceSessionModel {
  final String? className;
  final String? subjectName;
  final ClassModel? classModel;
  
  AttendanceSessionWithClass({
    required String id,
    required String classId,
    required DateTime date,
    String? startTime,
    String? endTime,
    required String createdBy,
    DateTime? createdAt,
    this.className,
    this.subjectName,
    this.classModel,
  }) : super(
    id: id,
    classId: classId,
    date: date,
    startTime: startTime,
    endTime: endTime,
    createdBy: createdBy,
    createdAt: createdAt,
  );
}
