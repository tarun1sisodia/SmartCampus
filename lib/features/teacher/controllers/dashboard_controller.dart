import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';
import '../../../services/attendance_service.dart';
import '../../../utils/helpers/snackbar_helper.dart';

class DashboardController extends GetxController {
  final classService = ClassService();
  final attendanceService = AttendanceService();
  
  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final totalClasses = 0.obs;
  final totalStudents = 0.obs;
  final averageAttendance = 0.0.obs;
  
  // Map to store attendance stats for each class
  final classStats = <String, Map<String, dynamic>>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }
  
  // Load all dashboard data
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(message: 'You must be logged in to view the dashboard');
        return;
      }
      
      // Load classes
      final teacherClasses = await classService.getTeacherClasses(currentUser.id);
      classes.assignAll(teacherClasses);
      totalClasses.value = teacherClasses.length;
      
      // Load stats for each class
      classStats.clear();
      int totalStudentsCount = 0;
      double totalAttendancePercentage = 0.0;
      
      for (var classModel in teacherClasses) {
        final stats = await attendanceService.getAttendanceStatsForClass(classModel.id);
        classStats[classModel.id] = stats;
        
        // Get student count for this class
        final studentsCount = await _getStudentCountForClass(classModel.id);
        totalStudentsCount += studentsCount;
        
        // Add to total attendance percentage
        if (stats['totalSessions'] > 0) {
          totalAttendancePercentage += stats['averageAttendance'] as double;
        }
      }
      
      // Update totals
      totalStudents.value = totalStudentsCount;
      
      // Calculate average attendance across all classes
      if (teacherClasses.isNotEmpty) {
        averageAttendance.value = totalAttendancePercentage / teacherClasses.length;
      } else {
        averageAttendance.value = 0.0;
      }
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load dashboard data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get student count for a class
  Future<int> _getStudentCountForClass(String classId) async {
    try {
      final response = await Supabase.instance.client
          .from('class_students')
          .select('id')
          .eq('class_id', classId);
      
      return response.length;
    } catch (e) {
      print('Error getting student count: $e');
      return 0;
    }
  }
}