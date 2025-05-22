import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';
import '../../../services/attendance_service.dart';
import '../../../services/course_service.dart';
import '../../../services/subject_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../services/auth_service.dart';
import 'dart:async';

import '../../authentication/controllers/supabase_auth_controller.dart';

class DashboardController extends GetxController {
  final attendanceService = AttendanceService();
  final subjectService = SubjectService();
  final classService = ClassService();
  final courseService = CourseService();
  final biometricAuthService = Get.put(BiometricAuthService());

  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final totalClasses = 0.obs;
  final totalStudents = 0.obs;
  final averageAttendance = 0.0.obs;
  final isAuthenticated = false.obs;

  final List<StreamSubscription> _subscriptions = [];

  // Map to store attendance stats for each class
  final classStats = <String, Map<String, dynamic>>{}.obs;

  // these properties to the DashboardController class
  final searchQuery = ''.obs;
  final filteredClasses = <ClassModel>[].obs;

  // these for greeting animation
  final greeting = ''.obs;
  final showGreetingAnimation = true.obs;

  @override
  void onInit() {
    super.onInit();
    //print('DashboardController initialized');
    checkBiometricAuthentication();
    initializeGreeting();
    _setupRealtimeSubscriptions();
  }

  @override
  void onClose() {
    // Clean up subscriptions when controller is destroyed
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  Future<void> checkBiometricAuthentication() async {
    await biometricAuthService.checkBiometricAvailability();

    if (biometricAuthService.isBiometricEnabled.value &&
        biometricAuthService.isAvailable.value) {
      final authenticated =
          await biometricAuthService.authenticateWithBiometrics(
              customReason:
                  'Please authenticate to access the Smart Campus app');

      isAuthenticated.value = authenticated;

      if (authenticated) {
        loadDashboardData();
      } else {
        // If authentication fails, check if we should retry or redirect
        final shouldRetry = await Get.dialog<bool>(
              AlertDialog(
                title: Text('Authentication Failed'),
                content: Text('Would you like to try again?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldRetry) {
          checkBiometricAuthentication();
        } else {
          // Redirect to login
          final authController = Get.find<SupabaseAuthController>();
          authController.signOut();
        }
      }
    } else {
      // If biometrics not enabled or available, proceed normally
      isAuthenticated.value = true;
      loadDashboardData();
    }
  }

  void _setupRealtimeSubscriptions() {
    final classesSubscription = Supabase.instance.client
        .from('classes')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      loadDashboardData();
    });
    final recordsSubscription = Supabase.instance.client
        .from('attendance_records')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      loadDashboardData();
    });
    final studentSubscription = Supabase.instance.client
        .from('class_students')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      loadDashboardData();
    });
    final subjectSubscription = Supabase.instance.client
        .from('subjects')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      // _getStudentCountForClass();
    });
    _subscriptions.addAll(
        [classesSubscription, recordsSubscription, studentSubscription]);
  }

  // initialize greeting
  void initializeGreeting() {
    final baseGreeting = _getTimeBasedGreeting();
    final message = _getRandomGreetingMessage();
    greeting.value = '$baseGreeting! $message';

    // Auto-hide greeting animation after 5 seconds
    Future.delayed(const Duration(seconds: 3), () {
      showGreetingAnimation.value = false;
    });
  }

  // get time-based greeting
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // these random greeting messages
  final List<String> _greetingMessages = [
    'Welcome back',
    'Great to see you again',
    'Hope your classes go well today',
    'Making a difference every day',
  ];

  // get a random greeting message
  String _getRandomGreetingMessage() {
    final random = Random();
    return _greetingMessages[random.nextInt(_greetingMessages.length)];
  }

  // method to reset greeting animation (can be called when revisiting the screen)
  void resetGreetingAnimation() {
    showGreetingAnimation.value = true;

    // greeting text
    final baseGreeting = _getTimeBasedGreeting();
    final message = _getRandomGreetingMessage();
    greeting.value = '$baseGreeting! $message';

    // Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      showGreetingAnimation.value = false;
    });
  }

  bool hasError() {
    return TSnackBar.hasError(
      greeting.value,
      handle: true,
    );
  }

  Future<void> loadDashboardData() async {
    try {
      // THelperFunction.showAlert('Let me Check this','Alert is Running');
      //print('Loading dashboard data...');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        //print('No user is logged in');
        TSnackBar.showError(
          message: 'You must be logged in to view the dashboard',
        );
        return;
      }

      //print('Fetching classes for teacher: ${currentUser.id}');
      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );
      //print('Classes fetched: ${teacherClasses.length}');
      classes.assignAll(teacherClasses);
      filteredClasses.assignAll(teacherClasses);
      totalClasses.value = teacherClasses.length;

      classStats.clear();
      int totalStudentsCount = 0;
      double totalAttendancePercentage = 0.0;

      for (var classModel in teacherClasses) {
        //print('Fetching stats for class: ${classModel.id}');
        final stats = await attendanceService.getAttendanceStatsForClass(
          classModel.id,
        );
        //print('Stats for class ${classModel.id}: $stats');
        classStats[classModel.id] = stats;

        final studentsCount = await _getStudentCountForClass(classModel.id);
        //print('Student count for class ${classModel.id}: $studentsCount');
        totalStudentsCount += studentsCount;

        if (stats['totalSessions'] > 0) {
          totalAttendancePercentage += stats['averageAttendance'] as double;
        }
      }

      totalStudents.value = totalStudentsCount;
      if (teacherClasses.isNotEmpty) {
        averageAttendance.value =
            totalAttendancePercentage / teacherClasses.length;
      } else {
        averageAttendance.value = 0.0;
      }
      update();
      //print('Total students: $totalStudentsCount');
      //print('Average attendance: ${averageAttendance.value}');
    } catch (e) {
      //print('Error loading dashboard data: $e');
      TSnackBar.showError(
        message: 'Failed to load dashboard data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
      //print('Dashboard data loading complete');
    }
  }

  Future<int> _getStudentCountForClass(String classId) async {
    try {
      //print('Getting student count for class: $classId');
      final response = await Supabase.instance.client
          .from('class_students')
          .select('id')
          .eq('class_id', classId);

      //print('Student count response for class $classId: $response');
      return response.length;
    } catch (e) {
      //print('Error getting student count for class $classId: $e');
      return 0;
    }
  }

  Future<void> createInitialData() async {
    try {
      //print('Creating initial data...');
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        //print('No user is logged in');
        TSnackBar.showError(message: 'You must be logged in to create data.');
        return;
      }

      final classes = await classService.getTeacherClasses(currentUser.id);
      //print('Existing classes: ${classes.length}');

      if (classes.isEmpty) {
        //print('No classes found, creating sample data...');

        // Create a sample subject
        final subject = await subjectService.createSubject(
          'Operating Systems',
          'BCA301',
        );
        //print('Sample subject created: $subject');

        // Create a sample course
        try {
          final course = await courseService.createCourse(
            'Bachelors of Computer Application',
            'BCA',
          );
          //print('Sample course created: $course');

          // Create a sample class
          await classService.createClass(
            teacherId: currentUser.id,
            subjectId: subject.id,
            courseId: course.id,
            semester: 1,
            section: 'A',
          );
          //print('Sample class created');
        } catch (e) {
          //print('Error while creating course: $e');
          TSnackBar.showError(
            message: 'Failed to create course: ${e.toString()}',
          );
        }

        // Reload dashboard data
        await loadDashboardData();
      }
    } catch (e) {
      //print('Error creating initial data: $e');
      TSnackBar.showError(
        message: 'Failed to create initial data: ${e.toString()}',
      );
    }
  }

  void searchClasses(String query) {
    //print('Searching classes with query: $query');
    searchQuery.value = query.toLowerCase();
    if (query.isEmpty) {
      filteredClasses.assignAll(classes);
    } else {
      filteredClasses.assignAll(
        classes.where((classModel) {
          final matchesSubject =
              classModel.subjectName?.toLowerCase().contains(query) ?? false;
          final matchesCourse =
              classModel.courseName?.toLowerCase().contains(query) ?? false;
          final matchesSection =
              classModel.section?.toLowerCase().contains(query) ?? false;

          //print(
          // 'Class ${classModel.id}: matchesSubject=$matchesSubject, matchesCourse=$matchesCourse, matchesSection=$matchesSection');
          return matchesSubject || matchesCourse || matchesSection;
        }).toList(),
      );
    }
    update();
    // //print('Filtered classes: ${filteredClasses.length}');
  }

  // Add a method to manually trigger biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    final authenticated = await biometricAuthService.authenticateWithBiometrics(
        customReason: 'Please authenticate to access sensitive information');

    isAuthenticated.value = authenticated;
    return authenticated;
  }
}
