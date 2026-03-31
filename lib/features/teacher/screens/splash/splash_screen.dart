import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../app/bindings/app_bindings.dart';
import '../../../common/utils/constants/image_strings.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../navigation_menu.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../authentication/controllers/supabase_auth_controller.dart';
import '../../../common/ui_patterns/ui_style.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
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

    // Navigate after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    final supabaseAuthController = Get.put(SupabaseAuthController());
    final storageService = Get.find<StorageService>();
    final biometricAuthService = Get.put(BiometricAuthService());

    final bool onboardingCompleted = storageService.getOnboardingStatus();
    if (!onboardingCompleted) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final bool isSessionValid = await supabaseAuthController.isSessionValid();

    if (isSessionValid) {
      final dashboardController = Get.put(DashboardController());
      await dashboardController.initializeAfterSplash();

      if (Platform.isLinux) {
        Get.offAllNamed(AppRoutes.home);
      } else if (Platform.isAndroid || Platform.isIOS) {
        await biometricAuthService.checkBiometricAvailability();
        final bool biometricEnabled =
            biometricAuthService.isBiometricEnabled.value;

        if (biometricEnabled && biometricAuthService.isAvailable.value) {
          final authenticated =
              await biometricAuthService.authenticateWithBiometrics(
                  customReason: 'Access Smart Campus');
          if (authenticated) {
            dashboardController.isAuthenticated.value = true;
            Get.offAll(() => NavigationMenu(), binding: HomeBinding(), transition: Transition.fadeIn);
          } else {
            Get.offAllNamed(AppRoutes.login);
          }
        } else {
          dashboardController.splashAuthenticationCompleted.value = true;
          Get.offAll(() => NavigationMenu(), binding: HomeBinding(), transition: Transition.fadeIn);
        }
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure UIStyleController is initialized to get style
    final uiController = Get.put(UIStyleController());
    final style = uiController.currentStyle.value;

    return Scaffold(
      backgroundColor: _getBg(style),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => Opacity(opacity: _fadeAnimation.value, child: child),
              child: Image.asset(TImageStrings.applogoTransparentPNG, width: 140, height: 140, color: _getLogoColor(style)),
            ),
            const SizedBox(height: 48),
            _buildSplashVariant(style),
          ],
        ),
      ),
    );
  }

  Widget _buildSplashVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const _SplashLabel(label: 'ENTERPRISE_SYSTEM_V.1.0', color: Color(0xFF0F172A));
      case UIStyle.cyberpunkNeon:
        return _SplashNeon(label: 'UPLINKING...', color: const Color(0xFF00F5FF));
      case UIStyle.softMinimalist:
        return const _SplashLabel(label: 'Welcome', color: Colors.black26);
      case UIStyle.brutalistBold:
        return const _SplashLabel(label: 'SMART_CAMPUS', color: Colors.black, isBold: true);
      case UIStyle.academicClassic:
        return const _SplashLabel(label: 'Scholarly Insight', color: Color(0xFF8B4513));
      default:
        return Lottie.asset(TImageStrings.hellorobo, width: 120, height: 120);
    }
  }

  Color _getBg(UIStyle style) {
    switch (style) {
      case UIStyle.cyberpunkNeon: return const Color(0xFF000814);
      case UIStyle.academicClassic: return const Color(0xFFFAF7F0);
      case UIStyle.industrialCorporate: return const Color(0xFFF8FAFC);
      case UIStyle.neumorphism: return const Color(0xFFE0E5EC);
      default: return Colors.white;
    }
  }

  Color? _getLogoColor(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate: return const Color(0xFF0F172A);
      case UIStyle.cyberpunkNeon: return const Color(0xFF00F5FF);
      case UIStyle.brutalistBold: return Colors.black;
      case UIStyle.academicClassic: return const Color(0xFF2D2E32);
      default: return null;
    }
  }
}

class _SplashLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool isBold;
  const _SplashLabel({required this.label, required this.color, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontSize: 13, letterSpacing: 2));
  }
}

class _SplashNeon extends StatelessWidget {
  final String label;
  final Color color;
  const _SplashNeon({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Courier')),
        const SizedBox(height: 12),
        Container(width: 80, height: 2, color: color, margin: const EdgeInsets.symmetric(horizontal: 4)),
      ],
    );
  }
}
