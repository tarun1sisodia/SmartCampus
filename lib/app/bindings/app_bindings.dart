import 'package:attedance__/features/teacher/controllers/all_sessions_controller.dart';
import 'package:attedance__/features/teacher/controllers/feedback_controller.dart';
import 'package:attedance__/features/teacher/controllers/teacher_profile_controller.dart';
import 'package:attedance__/navigation_menu.dart';
import 'package:attedance__/services/storage_service.dart';

import '../../features/authentication/controllers/change_password_controller.dart';
import '../../features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';
import '../../features/authentication/controllers/forgot_password_controller.dart';
import '../../features/authentication/controllers/login_controller.dart';
import '../../features/authentication/controllers/signup_controller.dart';
import '../../features/authentication/controllers/supabase_auth_controller.dart';
import '../../features/teacher/controllers/attendance_controller.dart';
import '../../features/teacher/controllers/attendance_reports_controller.dart';
import '../../features/teacher/controllers/carousel_attendance_controller.dart';
import '../../features/teacher/controllers/class_controller.dart';
import '../../features/teacher/controllers/dashboard_controller.dart';
import '../../features/teacher/controllers/student_detail_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A class that manages all controller bindings for the app
/// This centralizes dependency injection and improves performance
class AppBindings {
  /// Initialize all bindings that should be available globally
  static void initGlobalBindings() {
    //print('Initializing global bindings by AppBindings');
    // Auth controllers with permanent: true will persist throughout the app lifecycle
    Get.put(SupabaseAuthController(), permanent: true);
  }

  /// Onboarding bindings
  static void registerOnboardingBindings() {
    //print('Registering onboarding bindings');
    Get.lazyPut(() => OnboardingController(), fenix: true);
  }

  /// Login bindings
  static void registerLoginBindings() {
    //print('Registering login bindings');
    Get.lazyPut(() => LoginController(), fenix: true);
  }

  /// Signup bindings
  static void registerSignupBindings() {
    //print('Registering signup bindings');
    Get.lazyPut(() => SignupController(), fenix: true);
  }

  /// Forgot password bindings
  static void registerForgotPasswordBindings() {
    //print('Registering forgot password bindings');
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
  }

  /// Home screen bindings (includes all controllers needed for the home screen)
  static void registerHomeBindings() {
    //print('Registering home bindings');
    Get.lazyPut(() => TeacherProfileController(), fenix: true);
  }

  static void createClassScreen() {
    //print('Creating class screen');
    Get.lazyPut(() => ClassController(), fenix: true);
  }

  static void registerChangePasswordBindings() {
    //print('Registering change password bindings');
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
  }

  static void feedbackDialog() {
    //print('Registering feedback dialog bindings');
    Get.lazyPut(() => FeedbackController(), fenix: true);
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing splash bindings');
    // Only initialize services needed for the splash screen
    Get.put(StorageService(), permanent: true);
    // You could also initialize any controllers specific to the splash screen
    // but avoid controllers that require authentication
  }
}

/// Individual bindings classes for use with GetX routing
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing onboarding dependencies');
    AppBindings.registerOnboardingBindings();
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing signup dependencies');
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
    //print('Initializing login dependencies');
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
    //print('Initializing forgot password dependencies');
    AppBindings.registerForgotPasswordBindings();
  }
}

class TeacherProfileBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing teacher profile dependencies');
    AppBindings.registerHomeBindings();
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing home dependencies');
    // Check if user is authenticated before binding controllers
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      //print('User authenticated, initializing controllers');
      Get.lazyPut(() => DashboardController(), fenix: true);
      Get.lazyPut(() => ClassController(), fenix: true);
      Get.lazyPut(() => AttendanceController(), fenix: true);
      Get.lazyPut(() => NavigationController(), fenix: true);
      //line to initialize CarouselAttendanceController
      Get.lazyPut(() => CarouselAttendanceController(), fenix: true);
    }
  }
}

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing change password dependencies');
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
    //print('Initializing create class dependencies');
    Get.lazyPut(() => ClassController(), fenix: true);
  }
}

// Add these bindings
class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing reports dependencies');
    Get.lazyPut(() => AttendanceReportsController(), fenix: true);
  }
}

class StudentDetailBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing student detail dependencies');
    Get.lazyPut(() => StudentDetailController(), fenix: true);
  }
}

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing attendance dependencies');
    Get.lazyPut(() => AttendanceController(), fenix: true);
  }
}

//for the Messages screen
class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing messages dependencies');
    // Don't initialize OnboardingController here!
    // Instead, use the appropriate controller for messages
    // For now, we'll use HomeBinding since it has the necessary controllers
    HomeBinding().dependencies();
  }
}

//for the Settings screen
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    //print('Initializing settings dependencies');
    // Don't initialize OnboardingController here!
    // Instead, use the appropriate controller for settings
    // For now, we'll use HomeBinding since it has the necessary controllers
    HomeBinding().dependencies();
  }
}

class CarouselAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure the attendance controller is available
    if (!Get.isRegistered<AttendanceController>()) {
      //print('Initializing AttendanceController...inside the bindings');
      Get.put(AttendanceController());
      //print('AttendanceController initialized. inside the bindings ');
    } else {
      // If it's already registered, find it
      Get.find<AttendanceController>();
      //print('AttendanceController found. inside the bindings');
    }

    // Initialize the carousel attendance controller
    Get.lazyPut(() => CarouselAttendanceController());
  }
}

class AllSessionsBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure the attendance controller is available
    if (!Get.isRegistered<AttendanceController>()) {
      Get.lazyPut(() => AttendanceController());
    }

    // Initialize the all sessions controller
    Get.lazyPut(() => AllSessionsController());
  }
}
