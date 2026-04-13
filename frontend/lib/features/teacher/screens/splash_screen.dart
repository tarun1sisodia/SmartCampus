import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../app/bindings/app_bindings.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/image_strings.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../app/routes/app_routes.dart';
import '../../../navigation_menu.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../authentication/controllers/supabase_auth_controller.dart';
import 'dart:io';

import '../controllers/dashboard_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to appropriate screen after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
        // Get.offAll(DashboardScreen());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Check if user is logged in
    final supabaseAuthController = Get.put(SupabaseAuthController());
    final storageService = Get.find<StorageService>();
    final biometricAuthService = Get.put(BiometricAuthService());

    // Check onboarding status first
    final bool onboardingCompleted = storageService.getOnboardingStatus();
    if (!onboardingCompleted) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    // Check if session is valid
    final bool isSessionValid = await supabaseAuthController.isSessionValid();

    if (isSessionValid) {
      // User is authenticated
      final dashboardController = Get.put(DashboardController());
      await dashboardController.initializeAfterSplash();

      if (Platform.isLinux) {
        // Bypass biometric authentication for Linux
        Get.offAllNamed(AppRoutes.home);
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Check if biometric authentication is enabled
        await biometricAuthService.checkBiometricAvailability();
        final bool biometricEnabled =
            biometricAuthService.isBiometricEnabled.value;

        if (biometricEnabled && biometricAuthService.isAvailable.value) {
          // If biometric is enabled, require authentication before proceeding
          final authenticated =
              await biometricAuthService.authenticateWithBiometrics(
                  customReason: 'To Access the Smart Campus app');
          if (authenticated) {
            // Mark authentication as completed in splash
            dashboardController.isAuthenticated.value = true;

            // Use Get.offAll instead of Get.offAllNamed to bypass middleware
            Get.offAll(
              () => NavigationMenu(),
              binding: HomeBinding(),
              transition: Transition.fadeIn,
            );
          } else {
            Get.snackbar('Oops', 'better luck next time.');
            // If biometric auth fails, go to login screen but don't sign out
            // This gives the user a chance to log in with credentials
            Get.offAllNamed(AppRoutes.login);
          }
        } else {
          // No biometric required, proceed to home
          dashboardController.splashAuthenticationCompleted.value = true;

          // Use Get.offAll instead of Get.offAllNamed to bypass middleware
          Get.offAll(
            () => NavigationMenu(),
            binding: HomeBinding(),
            transition: Transition.fadeIn,
          );
        }
      }
    } else {
      // Session invalid or expired, go to login
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.dark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(opacity: _fadeAnimation.value, child: child);
              },
              child: Image.asset(
                TImageStrings.applogoTransparentPNG,
                width: 150,
                height: 150,
              ),
            ),

            const SizedBox(height: 30),

            // Loading animation
            SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset(
                TImageStrings.hellorobo,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // App name with fade animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(opacity: _fadeAnimation.value, child: child);
              },
              child: Text(
                TTexts.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? TColors.yellow : TColors.purple,
                    ),
              ),
            ),

            const SizedBox(height: 10),

            // Tagline with fade animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(opacity: _fadeAnimation.value, child: child);
              },
              child: Text(
                TTexts.attendanceSubtitle2,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: dark ? Colors.white70 : TColors.dark54,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
