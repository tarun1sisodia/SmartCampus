import 'package:attedance__/features/splash/splash_screen.dart';

import '../../app/bindings/app_bindings.dart';
import '../../features/authentication/screens/change_password/change_password_screen.dart';
import '../../features/authentication/screens/forgot_password/forgot_password_2.dart';
import '../../features/authentication/screens/forgot_password/reset_password_confirmation.dart';
import '../../features/authentication/screens/login/login.dart';
import '../../features/authentication/screens/onboarding/onboarding.dart';
import '../../features/authentication/screens/signup/signup.dart';
import '../../features/authentication/screens/signup/singup_widgets/verify_email_screen.dart';
import '../../features/teacher/bindings/all_sessions_binding.dart';
import '../../features/teacher/bindings/carousel_attendance_binding.dart';
import '../../features/teacher/screens/about_screen.dart';
import '../../features/teacher/screens/all_sessions_screen.dart';
import '../../features/teacher/screens/attendance_reports_screen.dart';
import '../../features/teacher/screens/calendar_screen.dart';
import '../../features/teacher/screens/carousel_attendance_screen.dart';
import '../../features/teacher/screens/feedback_screen.dart';
import '../../features/teacher/screens/help_screen.dart';
import '../../features/teacher/screens/import_data_screen.dart';
import '../../features/teacher/screens/notifications_screen.dart';
import '../../features/teacher/screens/reports_screen.dart';
import '../../features/teacher/screens/student_detail_screen.dart';
import '../../features/teacher/screens/teacher_messages_screen.dart';
import '../../features/teacher/screens/teacher_settings_screen.dart';
import '../../navigation_menu.dart';
import 'package:get/get.dart';

/// A class that manages all routes for the app
class AppRoutes {
  /// Route names as constants to avoid typos
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetConfirmation = '/reset-confirmation';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home'; // Add home route
  static const String attendanceReports = '/attendance-reports';
  static const String studentDetail = '/student-detail';
  // Add these new route constants
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String message = '/message';
  static const String help = '/help';
  static const String feedback = '/feedback';
  static const String about = '/about';
  static const String export = '/export';
  static const String import = '/import';
  static const String notifications = '/notifications';
  static const String calendar = '/calendar';
  static const String carouselAttendance = '/CarouselAttendanceScreen';
  static const String changePassword = '/change-password';
  static const String allSessions = '/all-sessions';

  /// Get all application routes
  static List<GetPage> routes = [
    // Add this to your routes

    GetPage(
      name: splash,
      page: () => SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboarding,
      page: () => Onboarding(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: changePassword,
      page: () => ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: login,
      page: () => Login(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signup,
      page: () => Signup(),
      binding: SignupBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: resetConfirmation,
      page: () {
        final email = Get.arguments as String;
        return ResetPasswordConfirmationScreen(email: email);
      },
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: verifyEmail,
      page: () {
        final email = Get.arguments as String;
        return VerifyEmailScreen(email: email);
      },
      binding: SignupBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => NavigationMenu(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: carouselAttendance,
      page: () => CarouselAttendanceScreen(),
      binding: CarouselAttendanceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: reports,
      page: () => ReportsScreen(),
      binding: ReportsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: message,
      page: () => const TeacherMessagesScreen(),
      binding: MessagesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const TeacherSettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: help,
      page: () => const HelpScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: about,
      page: () => const AboutScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: import,
      page: () => const ImportDataScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: calendar,
      page: () => const CalendarScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: attendanceReports,
      page: () => AttendanceReportsScreen(),
      binding: ReportsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: studentDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return StudentDetailScreen(
          student: args['student'],
          classId: args['classId'],
        );
      },
      binding: StudentDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.allSessions,
      page: () => AllSessionsScreen(),
      binding: AllSessionsBinding(),
    ),
  ];

  /// Navigate to the initial route based on app state
  static String getInitialRoute() {
    return splash; // Change this to the desired initial route
  }
}
