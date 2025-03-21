import 'package:attedance__/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';
import 'package:attedance__/features/authentication/controllers/forgot_password_controller.dart';
import 'package:attedance__/features/authentication/controllers/login_controller.dart';
import 'package:attedance__/features/authentication/controllers/signup_controller.dart';
import 'package:attedance__/features/authentication/controllers/supabase_auth_controller.dart';
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
}

/// Individual bindings classes for use with GetX routing
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    AppBindings.registerOnboardingBindings();
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    AppBindings.registerLoginBindings();
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    AppBindings.registerSignupBindings();
  }
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    AppBindings.registerForgotPasswordBindings();
  }
}