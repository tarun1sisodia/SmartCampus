import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../models/attendance_session_model.dart';
import '../../../models/student_model.dart';
import '../../../models/class_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AttendanceReportsController extends GetxController {
  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final selectedClassId = ''.obs;
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final sessions = <AttendanceSessionModel>[].obs;
  final students = <StudentModel>[].obs;
  final searchQuery = ''.obs;

  // Statistics
  final averageAttendance = 0.0.obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;
  
  final studentStats = <String, Map<String, dynamic>>{}.obs;
  final filteredStudents = <StudentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadClasses();
  }

  Future<void> loadClasses() async {
    try {
      isLoading.value = true;
      // Fetch classes for dropdown
      final response = await ApiClient.dio.get('/attendance/sessions'); // Simplified: get unique classes from sessions or hit /classes
      // For now, assume /attendance/sessions gives enough info or user hits /classes
      // But we'll just hit a generic /analytics/teacher/me for global stats
      await loadAttendanceData();
    } catch (e) {
      debugPrint('Error loading classes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAttendanceData() async {
    try {
      isLoading.value = true;
      
      final results = await Future.wait([
        ApiClient.dio.get('/analytics/teacher/me', queryParameters: {
          'startDate': startDate.value.toIso8601String(),
          'endDate': endDate.value.toIso8601String(),
        }),
        // sessions
      ]);

      final statsData = results[0].data['data'];
      presentCount.value = statsData['presentCount'] ?? 0;
      absentCount.value = statsData['absentCount'] ?? 0;
      averageAttendance.value = (statsData['overallAttendance'] ?? 0.0).toDouble();
      
      update();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(message: 'Failed to load report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _filterStudents();
  }

  void _filterStudents() {
    if (searchQuery.value.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredStudents.assignAll(students.where((s) => s.name.toLowerCase().contains(query)).toList());
    }
  }

  Future<void> exportAttendanceReport() async {
    TSnackBar.showInfo(message: 'Exporting report...');
    // Implementation for CSV export can be added here if requested
  }
}
