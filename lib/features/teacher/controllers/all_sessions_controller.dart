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
  void onInit() {
    super.onInit();
    loadAllSessions();
    loadClasses();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
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
