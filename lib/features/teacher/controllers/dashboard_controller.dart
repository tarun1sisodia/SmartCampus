import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';
import '../../../services/attendance_service.dart';
import '../../../services/course_service.dart';
import '../../../services/realtime_service.dart';
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
  // Get RealtimeService instance
  late final RealtimeService realtimeService;

  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final totalClasses = 0.obs;
  final totalStudents = 0.obs;
  final averageAttendance = 0.0.obs;
  final isAuthenticated = false.obs;
  //property to track if splash authentication was completed
  final RxBool splashAuthenticationCompleted = RxBool(false);

  // Real-time connection status
  final isRealtimeConnected = true.obs;
  final lastUpdated = DateTime.now().obs;

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
    _initializeRealtimeService();
    initializeGreeting();

    // Wait until the Splash screen has completed authentication before loading
    // data. This avoids calling loadDashboardData() (and its snackbars) while
    // there is no Overlay widget in the widget tree.
    ever(splashAuthenticationCompleted, (bool completed) {
      if (completed) {
        loadDashboardData();
      }
    });
  }

  @override
  void onClose() {
    // Clean up subscriptions when controller is destroyed
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  // Initialize the realtime service
  void _initializeRealtimeService() {
    try {
      realtimeService = Get.find<RealtimeService>();
      print('Found existing RealtimeService instance');
    } catch (e) {
      print('RealtimeService not found, creating new instance');
      realtimeService = Get.put(RealtimeService());
    }

    _setupRealtimeSubscriptions();
  }

  // Set up real-time subscriptions
  void _setupRealtimeSubscriptions() {
    // Subscribe to classes stream
    final classesSubscription = realtimeService.classesStream.listen(
      (data) {
        print('Real-time classes update in Dashboard: ${data.length} classes');
        _handleClassesUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        print('Error in classes stream (Dashboard): $error');
        isRealtimeConnected.value = false;
      },
    );

    // Subscribe to students stream for total count updates
    final studentsSubscription = realtimeService.studentsStream.listen(
      (data) {
        print(
            'Real-time students update in Dashboard: ${data.length} students');
        _updateTotalStudents();
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        print('Error in students stream (Dashboard): $error');
      },
    );

    // Subscribe to attendance stream for stats updates
    final attendanceSubscription = realtimeService.attendanceStream.listen(
      (data) {
        print(
            'Real-time attendance update in Dashboard: ${data.length} records');
        _updateAttendanceStats();
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        print('Error in attendance stream (Dashboard): $error');
      },
    );

    // Monitor RealtimeService connection status
    final connectionSubscription = realtimeService.isConnected.listen(
      (isConnected) {
        isRealtimeConnected.value = isConnected;
        if (isConnected) {
          print('Real-time connection restored in Dashboard');
          // Refresh data when connection is restored
          loadDashboardData();
        } else {
          print('Real-time connection lost in Dashboard');
        }
      },
    );

    _subscriptions.addAll([
      classesSubscription,
      studentsSubscription,
      attendanceSubscription,
      connectionSubscription,
    ]);

    isRealtimeConnected.value = realtimeService.isConnected.value;
  }

  // Handle real-time classes updates
  void _handleClassesUpdate(List<Map<String, dynamic>> data) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Filter classes for current teacher and convert to ClassModel
      final teacherClasses = <ClassModel>[];

      for (var classData in data) {
        if (classData['teacher_id'] == currentUser.id) {
          try {
            // Fetch related subject and course data
            final subjectData = await Supabase.instance.client
                .from('subjects')
                .select()
                .eq('id', classData['subject_id'])
                .single();

            final courseData = await Supabase.instance.client
                .from('courses')
                .select()
                .eq('id', classData['course_id'])
                .single();

            final classModel = ClassModel(
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

            teacherClasses.add(classModel);
          } catch (e) {
            print(
                'Error fetching related data for class ${classData['id']}: $e');
          }
        }
      }

      // Update classes list
      classes.assignAll(teacherClasses);
      totalClasses.value = teacherClasses.length;

      // Update filtered classes based on current search
      if (searchQuery.value.isNotEmpty) {
        searchClasses(searchQuery.value);
      } else {
        filteredClasses.assignAll(teacherClasses);
      }

      // Update attendance stats for all classes
      _updateAttendanceStats();

      print(
          'Dashboard classes updated via real-time: ${teacherClasses.length} classes');
    } catch (e) {
      print('Error handling classes update in Dashboard: $e');
    }
  }

  // Update total students count
  void _updateTotalStudents() async {
    try {
      int totalStudentsCount = 0;

      for (var classModel in classes) {
        final studentsCount = await _getStudentCountForClass(classModel.id);
        totalStudentsCount += studentsCount;
      }

      totalStudents.value = totalStudentsCount;
      print('Total students updated: $totalStudentsCount');
    } catch (e) {
      print('Error updating total students: $e');
    }
  }

  // Update attendance statistics
  void _updateAttendanceStats() async {
    try {
      classStats.clear();
      double totalAttendancePercentage = 0.0;

      for (var classModel in classes) {
        final stats = await attendanceService.getAttendanceStatsForClass(
          classModel.id,
        );
        classStats[classModel.id] = stats;

        if (stats['totalSessions'] > 0) {
          totalAttendancePercentage += stats['averageAttendance'] as double;
        }
      }

      if (classes.isNotEmpty) {
        averageAttendance.value = totalAttendancePercentage / classes.length;
      } else {
        averageAttendance.value = 0.0;
      }

      print('Attendance stats updated: ${averageAttendance.value}%');
    } catch (e) {
      print('Error updating attendance stats: $e');
    }
  }

  // Get connection status string
  String getConnectionStatus() {
    if (!isRealtimeConnected.value) {
      return 'Disconnected';
    }

    final now = DateTime.now();
    final difference = now.difference(lastUpdated.value);

    if (difference.inSeconds < 30) {
      return 'Live';
    } else if (difference.inSeconds < 60) {
      return 'Updated ${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    } else {
      return 'Updated ${difference.inHours}h ago';
    }
  }

  // Reconnect to real-time service
  Future<void> reconnectRealtime() async {
    try {
      print('Attempting to reconnect to real-time service from Dashboard...');
      await realtimeService.forceReconnect();
      print('Successfully reconnected to real-time service');
    } catch (e) {
      print('Failed to reconnect to real-time service: $e');
    }
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
        if (Get.overlayContext == null) {
          // If no overlay, just redirect to login or do nothing
          final authController = Get.find<SupabaseAuthController>();
          authController.signOut();
          return;
        }

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
        if (Get.overlayContext != null) {
          TSnackBar.showError(
            message: 'You must be logged in to view the dashboard',
          );
        }
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
      if (Get.overlayContext != null) {
        TSnackBar.showError(
          message: 'Failed to load dashboard data: ${e.toString()}',
        );
      }
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
