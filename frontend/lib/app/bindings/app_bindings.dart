import '../../features/teacher/controllers/feedback_controller.dart';
import '../../features/teacher/controllers/teacher_profile_controller.dart';

import '../../features/authentication/controllers/change_password_controller.dart';
import '../../features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';
import '../../features/authentication/controllers/forgot_password_controller.dart';
import '../../features/authentication/controllers/login_controller.dart';
import '../../features/teacher/controllers/attendance_controller.dart';
import '../../features/teacher/controllers/attendance_reports_controller.dart';
import '../../features/teacher/controllers/carousel_attendance_controller.dart';
import '../../features/teacher/controllers/dashboard_controller.dart';
import 'package:get/get.dart';

import '../../navigation_menu.dart';
import '../../services/storage_service.dart';
import '../../core/services/offline_sync_service.dart';

class AppBindings {
  static void initGlobalBindings() {
    // Core Background Services
    if (!Get.isRegistered<OfflineSyncService>()) {
      Get.put(OfflineSyncService(), permanent: true);
    }
    
    // Lazy Put Attendance Controller since it's used globally for current session
    if (!Get.isRegistered<AttendanceController>()) {
      Get.lazyPut<AttendanceController>(() => AttendanceController(), fenix: true);
    }
  }

  static void initAuthenticatedBindings() {
    // Additional bindings after login
  }

  static void registerOnboardingBindings() {
    Get.lazyPut(() => OnboardingController(), fenix: true);
  }

  static void registerLoginBindings() {
    Get.lazyPut(() => LoginController(), fenix: true);
  }

  static void registerForgotPasswordBindings() {
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
  }

  static void registerHomeBindings() {
    Get.lazyPut(() => TeacherProfileController(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
  }

  static void registerChangePasswordBindings() {
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
  }

  static void feedbackDialog() {
    Get.lazyPut(() => FeedbackController(), fenix: true);
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => AttendanceController(), fenix: true);
    Get.lazyPut(() => NavigationController(), fenix: true);
    Get.lazyPut(() => CarouselAttendanceController(), fenix: true);
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(), fenix: true);
  }
}

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceReportsController(), fenix: true);
  }
}

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceController(), fenix: true);
  }
}

class AllSessionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllSessionsController(), fenix: true);
  }
}
