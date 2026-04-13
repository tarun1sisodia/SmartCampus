import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';
import '../../../services/attendance_service.dart';
import '../../../services/course_service.dart';
import '../../../services/realtime_service.dart';
import '../../../services/biometric_auth_service.dart';
import '../../../services/subject_service.dart';
import 'dart:async';

import '../../../services/student_service.dart';
import '../../../services/local_storage_service.dart';
import '../../authentication/controllers/supabase_auth_controller.dart';

class DashboardController extends GetxController {
  final attendanceService = AttendanceService();
  final subjectService = SubjectService();
  final studentService = StudentService();
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
  bool _hasInitialized = false;

  @override
  void onInit() {
    super.onInit();
    //debugPrint('DashboardController initialized');
    _loadCachedData();
    _initializeRealtimeService();
    checkBiometricAuthentication();
    initializeGreeting();
    loadDashboardData();
  }

  final _localStorage = LocalStorageService();

  Future<void> _loadCachedData() async {
    try {
      final cachedClasses = await _localStorage.getOfflineClasses();
      if (cachedClasses.isNotEmpty) {
        classes.assignAll(cachedClasses);
        filteredClasses.assignAll(cachedClasses);
        totalClasses.value = cachedClasses.length;
        debugPrint('Loaded ${cachedClasses.length} classes from local cache');
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
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
      debugPrint('Found existing RealtimeService instance');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('RealtimeService not found, creating new instance');
      realtimeService = Get.put(RealtimeService());
    }
    
    _setupRealtimeSubscriptions();
  }

  // Set up real-time subscriptions
  void _setupRealtimeSubscriptions() {
    // Subscribe to classes stream
    final classesSubscription = realtimeService.classesStream.listen(
      (data) {
        debugPrint('Real-time classes update in Dashboard: ${data.length} classes');
        _handleClassesUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in classes stream (Dashboard): $error');
        isRealtimeConnected.value = false;
      },
    );

    // Subscribe to students stream for total count updates
    final studentsSubscription = realtimeService.studentsStream.listen(
      (data) {
        debugPrint(
            'Real-time students update in Dashboard: ${data.length} students');
        _updateTotalStudents();
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in students stream (Dashboard): $error');
      },
    );

    // Subscribe to attendance stream for stats updates
    final attendanceSubscription = realtimeService.attendanceStream.listen(
      (data) {
        debugPrint(
            'Real-time attendance update in Dashboard: ${data.length} records');
        _updateAttendanceStats();
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in attendance stream (Dashboard): $error');
      },
    );

    // Monitor RealtimeService connection status
    final connectionSubscription = realtimeService.isConnected.listen(
      (isConnected) {
        isRealtimeConnected.value = isConnected;
        if (isConnected) {
          debugPrint('Real-time connection restored in Dashboard');
          if (splashAuthenticationCompleted.value) {
            loadDashboardData();
          }
        } else {
          debugPrint('Real-time connection lost in Dashboard');
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

      // 1. Collect all subject IDs, and course IDs
      final subjectIds =
          data.map((d) => d['subject_id'] as String).toSet().toList();
      final courseIds =
          data.map((d) => d['course_id'] as String).toSet().toList();

      // 2. Fetch all subjects and courses in batches
      final subjectsResponse = await Supabase.instance.client
          .from('subjects')
          .select()
          .inFilter('id', subjectIds);
      final coursesResponse = await Supabase.instance.client
          .from('courses')
          .select()
          .inFilter('id', courseIds);

      final subjectMap = {for (var s in subjectsResponse) s['id']: s['name']};
      final courseMap = {for (var c in coursesResponse) c['id']: c['name']};

      // 3. Map to ClassModel for current teacher
      final teacherClasses = <ClassModel>[];
      for (var classData in data) {
        if (classData['teacher_id'] == currentUser.id) {
          teacherClasses.add(ClassModel(
            id: classData['id'],
            teacherId: classData['teacher_id'],
            subjectId: classData['subject_id'],
            courseId: classData['course_id'],
            semester: classData['semester'],
            section: classData['section'],
            subjectName: subjectMap[classData['subject_id']],
            courseName: courseMap[classData['course_id']],
            createdAt: classData['created_at'] != null
                ? DateTime.parse(classData['created_at'])
                : null,
            updatedAt: classData['updated_at'] != null
                ? DateTime.parse(classData['updated_at'])
                : null,
          ));
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

    debugPrint(
        'Dashboard classes updated via real-time: ${teacherClasses.length} classes');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error handling classes update in Dashboard: $e');
    }
}

  void _updateTotalStudents() async {
    try {
      if (classes.isEmpty) {
        totalStudents.value = 0;
        return;
      }

      final classIds = classes.map((c) => c.id).toList();
      final countsMap = await studentService.getStudentCountsForClasses(classIds);
      
      int total = 0;
      countsMap.forEach((_, count) => total += (count as num).toInt());

      totalStudents.value = total;
      debugPrint('Total students updated (Batched): $total');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error updating total students: $e');
    }
  }

  void _updateAttendanceStats() async {
    try {
      if (classes.isEmpty) {
        _resetStats();
        return;
      }

      final classIds = classes.map((c) => c.id).toList();
      final newClassStats = await attendanceService.getAttendanceStatsForClasses(classIds);
      
      classStats.assignAll(newClassStats);

      double totalAttendancePercentage = 0.0;
      int activeClasses = 0;

      newClassStats.forEach((_, stats) {
        if ((stats['totalSessions'] ?? 0) > 0) {
          totalAttendancePercentage += (stats['averageAttendance'] ?? 0.0) as double;
          activeClasses++;
        }
      });

      averageAttendance.value = activeClasses > 0 
          ? totalAttendancePercentage / activeClasses 
          : 0.0;

      debugPrint('Attendance stats updated (Batched): ${averageAttendance.value}%');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error updating attendance stats: $e');
    }
  }

  void _resetStats() {
    classStats.clear();
    averageAttendance.value = 0.0;
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
      debugPrint('Attempting to reconnect to real-time service from Dashboard...');
      await realtimeService.forceReconnect();
      debugPrint('Successfully reconnected to real-time service');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Failed to reconnect to real-time service: $e');
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
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(
          message: 'You must be logged in to view the dashboard',
        );
        return;
      }

      // 1. Fetch classes
      final teacherClasses = await classService.getTeacherClasses(currentUser.id);
      classes.assignAll(teacherClasses);
      filteredClasses.assignAll(teacherClasses);
      totalClasses.value = teacherClasses.length;
      
      // Save for offline access
      for (final classModel in teacherClasses) {
        await _localStorage.saveClassOffline(classModel);
      }

      if (teacherClasses.isEmpty) {
        totalStudents.value = 0;
        averageAttendance.value = 0.0;
        classStats.clear();
        return;
      }

      final classIds = teacherClasses.map((c) => c.id).toList();

      // 2. Fetch stats and counts in parallel (Batched)
      final results = await Future.wait<dynamic>([
        attendanceService.getAttendanceStatsForClasses(classIds),
        studentService.getStudentCountsForClasses(classIds),
      ]);

      final newClassStats = results[0] as Map<String, Map<String, dynamic>>;
      final countsMap = results[1] as Map<String, int>;

      classStats.assignAll(newClassStats);

      // 3. Aggregate totals
      int totalStudentsCount = 0;
      double totalAttendancePercentage = 0.0;
      int activeClasses = 0;

      countsMap.forEach((_, count) => totalStudentsCount += count);
      
      newClassStats.forEach((_, stats) {
        if ((stats['totalSessions'] ?? 0) > 0) {
          totalAttendancePercentage += (stats['averageAttendance'] ?? 0.0) as double;
          activeClasses++;
        }
      });

      totalStudents.value = totalStudentsCount;
      averageAttendance.value = activeClasses > 0 
          ? totalAttendancePercentage / activeClasses 
          : 0.0;

      update();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(
        message: 'Failed to load dashboard data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeAfterSplash() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    splashAuthenticationCompleted.value = true;
    await loadDashboardData();
  }

  Future<void> createInitialData() async {
    try {
      //debugPrint('Creating initial data...');
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        //debugPrint('No user is logged in');
        TSnackBar.showError(message: 'You must be logged in to create data.');
        return;
      }

      final classes = await classService.getTeacherClasses(currentUser.id);
      //debugPrint('Existing classes: ${classes.length}');

      if (classes.isEmpty) {
        //debugPrint('No classes found, creating sample data...');

        // Create a sample subject
        final subject = await subjectService.createSubject(
          'Operating Systems',
          'BCA301',
        );
        //debugPrint('Sample subject created: $subject');

        // Create a sample course
        try {
          final course = await courseService.createCourse(
            'Bachelors of Computer Application',
            'BCA',
          );
          //debugPrint('Sample course created: $course');

          // Create a sample class
          await classService.createClass(
            teacherId: currentUser.id,
            subjectId: subject.id,
            courseId: course.id,
            semester: 1,
            section: 'A',
          );
          //debugPrint('Sample class created');
        } catch (e) {
          //debugPrint('Error while creating course: $e');
          TSnackBar.showError(
            message: 'Failed to create course: ${e.toString()}',
          );
        }

        // Reload dashboard data
        await loadDashboardData();
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //debugPrint('Error creating initial data: $e');
      TSnackBar.showError(
        message: 'Failed to create initial data: ${e.toString()}',
      );
    }
  }

  void searchClasses(String query) {
    //debugPrint('Searching classes with query: $query');
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

          //debugPrint(
          // 'Class ${classModel.id}: matchesSubject=$matchesSubject, matchesCourse=$matchesCourse, matchesSection=$matchesSection');
          return matchesSubject || matchesCourse || matchesSection;
        }).toList(),
      );
    }
    update();
    // //debugPrint('Filtered classes: ${filteredClasses.length}');
  }

  // Add a method to manually trigger biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    final authenticated = await biometricAuthService.authenticateWithBiometrics(
        customReason: 'Please authenticate to access sensitive information');

    isAuthenticated.value = authenticated;
    return authenticated;
  }
}
