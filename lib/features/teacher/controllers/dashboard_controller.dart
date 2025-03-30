import 'package:attedance__/services/course_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';
import '../../../services/attendance_service.dart';
import '../../../services/subject_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class DashboardController extends GetxController {
  final attendanceService = AttendanceService();
  final subjectService = SubjectService();
  final classService = ClassService();
  final courseService = CourseService();

  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final totalClasses = 0.obs;
  final totalStudents = 0.obs;
  final averageAttendance = 0.0.obs;

  // Map to store attendance stats for each class
  final classStats = <String, Map<String, dynamic>>{}.obs;

  // Add these properties to the DashboardController class
  final searchQuery = ''.obs;
  final filteredClasses = <ClassModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load all dashboard data
  /// Loads all data required for the teacher dashboard.
  ///
  /// This function is automatically called when the controller is initialized.
  /// It fetches all classes for the current user, and then fetches attendance
  /// statistics for each class. The total student count and average attendance
  /// percentage are then calculated and set on the controller.
  ///
  /// If there is an error fetching the data, a snack bar is shown with the
  /// error message.
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(
          message: 'You must be logged in to view the dashboard',
        );
        return;
      }

      // Load classes
      print('Fetching classes for teacher: ${currentUser.id}'); // Add this
      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );
      print('Classes fetched: ${teacherClasses.length}'); // Add this
      classes.assignAll(teacherClasses);
      filteredClasses.assignAll(teacherClasses);
      totalClasses.value = teacherClasses.length;

      // Load stats for each class
      classStats.clear();
      int totalStudentsCount = 0;
      double totalAttendancePercentage = 0.0;

      for (var classModel in teacherClasses) {
        final stats = await attendanceService.getAttendanceStatsForClass(
          classModel.id,
        );
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
        averageAttendance.value =
            totalAttendancePercentage / teacherClasses.length;
      } else {
        averageAttendance.value = 0.0;
      }
    } catch (e) {
      TSnackBar.showError(
        message: 'Failed to load dashboard data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get student count for a class
  /// Retrieves the number of students in a specific class.
  ///
  /// This function queries the 'class_students' table to count the number of
  /// students associated with the provided class ID.
  ///
  /// Returns an integer representing the total number of students in the class.
  /// If an error occurs during the query, the function logs the error and
  /// returns 0.
  ///
  /// [classId] The ID of the class for which to count students.

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

  // Add this to your DashboardController
  /// Initializes the dashboard with sample data if no classes exist for the user.
  ///
  /// This method checks if the current user has any associated classes. If no
  /// classes are found, it creates sample data including a subject, course, and
  /// class. The dashboard data is then reloaded to reflect these changes.
  ///
  /// If an error occurs during the data creation process, it is logged to the console.

  Future<void> createInitialData() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Check if user has any classes
      final classes = await classService.getTeacherClasses(currentUser.id);

      if (classes.isEmpty) {
        // Create a sample subject
        final subject = await subjectService.createSubject(
          'Operating Systems',
          'BCA301',
        );

        // Create a sample course
        final course = await courseService.createCourse(
          'Bachelors of Computer Application',
          'BCA',
        );

        // Create a sample class
        await classService.createClass(
          teacherId: currentUser.id,
          subjectId: subject.id,
          courseId: course.id,
          year: 1,
          section: 'A',
        );

        // Reload data
        await loadDashboardData();
      }
    } catch (e) {
      print('Error creating initial data: $e');
    }
  }

  // Add this method to the DashboardController class
  void searchClasses(String query) {
    searchQuery.value = query.toLowerCase();
    if (query.isEmpty) {
      filteredClasses.assignAll(classes);
    } else {
      filteredClasses.assignAll(
        classes.where((classModel) {
          return (classModel.subjectName?.toLowerCase().contains(query) ??
                  false) ||
              (classModel.courseName?.toLowerCase().contains(query) ?? false) ||
              (classModel.section?.toLowerCase().contains(query) ?? false);
        }).toList(),
      );
    }
  }
}
