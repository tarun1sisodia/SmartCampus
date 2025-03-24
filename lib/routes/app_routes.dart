import 'package:attedance__/bindings/app_bindings.dart';
import 'package:attedance__/features/authentication/screens/forgot_password/forgot_password_2.dart';
import 'package:attedance__/features/authentication/screens/forgot_password/reset_password_confirmation.dart';
import 'package:attedance__/features/authentication/screens/login/login.dart';
import 'package:attedance__/features/authentication/screens/onboarding/onboarding.dart';
import 'package:attedance__/features/authentication/screens/signup/signup.dart';
import 'package:attedance__/features/authentication/screens/signup/singup_widgets/verify_email_screen.dart';
import 'package:attedance__/navigation_menu.dart';
import 'package:get/get.dart';
import 'package:attedance__/features/teacher/screens/dashboard_screen.dart'; // Importing the DashboardScreen

/// A class that manages all routes for the app
class AppRoutes {
  /// Route names as constants to avoid typos
  static const String onboarding = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetConfirmation = '/reset-confirmation';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home'; // Add home route

  /// Get all application routes
  static List<GetPage> routes = [
    GetPage(
      name: onboarding,
      page: () => Onboarding(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => Login(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signup,
      page: () => const Signup(),
      binding: SignupBinding(), // Use a dedicated binding for signup
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
        // Get the email parameter from arguments
        final email = Get.arguments as String;
        return ResetPasswordConfirmationScreen(email: email);
      },
      binding: ForgotPasswordBinding(), // Reusing forgot password binding
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: verifyEmail,
      page: () {
        // Get the email parameter from arguments
        final email = Get.arguments as String;
        return VerifyEmailScreen(email: email);
      },
      binding: SignupBinding(), // Use signup binding for verification screen
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => NavigationMenu(), // Set DashboardScreen as home
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
  ];

  /// Navigate to the initial route based on app state
  static String getInitialRoute() {
    // This would typically check if onboarding is completed
    // For now, we'll just return the home route
    return home; // Change to home route
  }
}
