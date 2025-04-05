import 'package:flutter/material.dart';

class AppColors {
  // Primary color for the app
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Secondary color for accents
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF212121);

  // Swipe card colors
  static const Color presentSwipe = Color(0xFF4CAF50); // Green
  static const Color absentSwipe = Color(0xFFF44336); // Red
  static const Color unopenedCard = Color(0xFFE0E0E0); // Light grey
}

class AppConfig {
  static const String usersCollection = 'users';
  static const String classesCollection = 'classes';
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance';

  // Default animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Card dimensions
  static const double cardHeight = 240;
  static const double cardWidth = 320;

  // Bottom navigation settings
  static const double navBarIconSize = 24.0;
  static const Duration navBarAnimationDuration = Duration(milliseconds: 250);
}

// Firestore collection paths

// Routes used in the app
// class AppRoutes {
//   static const String login = '/login';
//   static const String home = '/home';
//   static const String profile = '/profile';
//   static const String classSelection = '/class-selection';
//   static const String attendance = '/attendance';
// }

// Asset paths
class AppAssets {
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String defaultStudentImage = 'assets/images/default_student.png';
  static const String logoImage = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
}
