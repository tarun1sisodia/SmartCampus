import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../common/utils/helpers/snackbar_helper.dart';
import '../../../../models/class_model.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final totalClasses = 0.obs;
  final totalStudents = 0.obs;
  final averageAttendance = 0.0.obs;
  final classes = <ClassModel>[].obs;
  final filteredClasses = <ClassModel>[].obs;
  final lastUpdated = DateTime.now().obs;
  final greeting = ''.obs;
  final showGreetingAnimation = true.obs;
  
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    initializeGreeting();
    loadDashboardData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => loadDashboardData());
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // 1. Fetch Today's Sessions and Stats
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Parallel requests for efficiency
      final results = await Future.wait([
        ApiClient.dio.get('/attendance/sessions?date=$today'),
        ApiClient.dio.get('/analytics/teacher/me'),
      ]);

      final sessionsData = results[0].data['data'] as List;
      final statsData = results[1].data['data'];

      // Update basic stats
      totalClasses.value = statsData['totalClasses'] ?? 0;
      totalStudents.value = statsData['totalStudents'] ?? 0;
      averageAttendance.value = (statsData['overallAttendance'] ?? 0.0).toDouble();

      lastUpdated.value = DateTime.now();
      update();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Dashboard Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void initializeGreeting() {
    final hour = DateTime.now().hour;
    String baseGreeting = 'Good Evening';
    if (hour < 12) baseGreeting = 'Good Morning';
    else if (hour < 17) baseGreeting = 'Good Afternoon';

    final messages = ['Welcome back', 'Great to see you again', 'Hope classes go well'];
    final message = messages[Random().nextInt(messages.length)];
    
    greeting.value = '$baseGreeting! $message';
    Future.delayed(const Duration(seconds: 3), () => showGreetingAnimation.value = false);
  }

  void searchClasses(String query) {
    if (query.isEmpty) {
      filteredClasses.assignAll(classes);
    } else {
      filteredClasses.assignAll(classes.where((c) => 
        (c.subjectName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (c.courseName?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList());
    }
  }

  Future<void> checkBiometricAuthentication() async {
    // Boilerplate for now, can be linked to BiometricService later
  }
}
