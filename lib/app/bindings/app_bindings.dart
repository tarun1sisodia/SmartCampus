import 'package:attedance__/features/authentication/controllers/change_password_controller.dart';
import 'package:attedance__/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';
import 'package:attedance__/features/authentication/controllers/forgot_password_controller.dart';
import 'package:attedance__/features/authentication/controllers/login_controller.dart';
import 'package:attedance__/features/authentication/controllers/signup_controller.dart';
import 'package:attedance__/features/authentication/controllers/supabase_auth_controller.dart';
import 'package:attedance__/features/teacher/controllers/attendance_controller.dart';
import 'package:attedance__/features/teacher/controllers/attendance_reports_controller.dart';
import 'package:attedance__/features/teacher/controllers/carousel_attendance_controller.dart';
import 'package:attedance__/features/teacher/controllers/class_controller.dart';
import 'package:attedance__/features/teacher/controllers/dashboard_controller.dart';
import 'package:attedance__/features/teacher/controllers/student_detail_controller.dart';
import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:attedance__/navigation_menu.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A class that manages all controller bindings for the app
/// This centralizes dependency injection and improves performance
class AppBindings {
  /// Initialize all bindings that should be available globally
  static void initGlobalBindings() {
    // Auth controllers with permanent: true will persist throughout the app lifecycle
    Get.put(SupabaseAuthController(), permanent: true);
  }

  /// Onboarding bindings
  static void registerOnboardingBindings() {
    Get.lazyPut(() => OnboardingController(), fenix: true);
  }

  /// Login bindings
  static void registerLoginBindings() {
    Get.lazyPut(() => LoginController(), fenix: true);
  }

  /// Signup bindings
  static void registerSignupBindings() {
    Get.lazyPut(() => SignupController(), fenix: true);
  }

  /// Forgot password bindings
  static void registerForgotPasswordBindings() {
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
  }

  /// Teacher profile bindings
  static void registerTeacherProfileBindings() {
    Get.lazyPut(() => TeacherProfileController(), fenix: true);
  }

  /// Home screen bindings (includes all controllers needed for the home screen)
  static void registerHomeBindings() {
    Get.lazyPut(() => TeacherProfileController(), fenix: true);
  }

  static void createClassScreen() {
    Get.lazyPut(() => ClassController(), fenix: true);
  }

  static void registerChangePasswordBindings() {
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
  }
}

/// Individual bindings classes for use with GetX routing
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    AppBindings.registerOnboardingBindings();
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    // First remove any existing instance to prevent dependency conflicts
    if (Get.isRegistered<SignupController>()) {
      Get.delete<SignupController>(force: true);
    }
    // Then create a new one
    Get.lazyPut(() => SignupController(), fenix: true);
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // First remove any existing instance to prevent dependency conflicts
    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>(force: true);
    }
    // Then create a new one
    Get.lazyPut(() => LoginController(), fenix: true);
  }
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    AppBindings.registerForgotPasswordBindings();
  }
}

class TeacherProfileBinding extends Bindings {
  @override
  void dependencies() {
    AppBindings.registerTeacherProfileBindings();
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Check if user is authenticated before binding controllers
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      Get.lazyPut(() => DashboardController(), fenix: true);
      Get.lazyPut(() => ClassController(), fenix: true);
      Get.lazyPut(() => AttendanceController(), fenix: true);
      Get.lazyPut(() => NavigationController(), fenix: true);
      // Add this line to initialize CarouselAttendanceController
      Get.lazyPut(() => CarouselAttendanceController(), fenix: true);
    }
  }
}

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    // First remove any existing instance to prevent dependency conflicts
    if (Get.isRegistered<ChangePasswordController>()) {
      Get.delete<ChangePasswordController>(force: true);
    }
    // Then create a new one
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
  }
}

class CreateClassScreen extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClassController(), fenix: true);
  }
}

// Add these bindings
class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceReportsController(), fenix: true);
  }
}

class StudentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentDetailController(), fenix: true);
  }
}

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceController(), fenix: true);
  }
}

// Add this for the Messages screen
class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    // Don't initialize OnboardingController here!
    // Instead, use the appropriate controller for messages
    // For now, we'll use HomeBinding since it has the necessary controllers
    HomeBinding().dependencies();
  }
}

// Add this for the Settings screen
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Don't initialize OnboardingController here!
    // Instead, use the appropriate controller for settings
    // For now, we'll use HomeBinding since it has the necessary controllers
    HomeBinding().dependencies();
  }
}
