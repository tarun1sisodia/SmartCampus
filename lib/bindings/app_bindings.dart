import 'package:attedance__/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';
import 'package:attedance__/features/authentication/controllers/forgot_password_controller.dart';
import 'package:attedance__/features/authentication/controllers/login_controller.dart';
import 'package:attedance__/features/authentication/controllers/signup_controller.dart';
import 'package:attedance__/features/authentication/controllers/supabase_auth_controller.dart';
import 'package:attedance__/features/teacher/controllers/attendance_controller.dart';
import 'package:attedance__/features/teacher/controllers/class_controller.dart';
import 'package:attedance__/features/teacher/controllers/dashboard_controller.dart';
import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:get/get.dart';

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
    Get.lazyPut(
      () => TeacherProfileController(),
      fenix: true,
    ); // Ensure proper binding
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
    Get.lazyPut(() => DashboardController(), fenix: true); // Ensure DashboardController is bound
    Get.lazyPut(() => ClassController(), fenix: true);
    Get.lazyPut(() => AttendanceController(), fenix: true);
  }
}
