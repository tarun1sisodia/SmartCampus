import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/image_strings.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../app/routes/app_routes.dart';
import '../../../services/storage_service.dart';

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
    final currentUser = Supabase.instance.client.auth.currentUser;

    // Get storage service to check if first launch
    final storageService = Get.find<StorageService>();
    final bool onboardingCompleted = storageService.getOnboardingStatus();

    if (currentUser != null) {
      //printnt('User authenticated: true');
      Get.offAllNamed(AppRoutes.home);
    } else if (onboardingCompleted) {
      //printnt('Onboarding completed: true');
      Get.offAllNamed(AppRoutes.login);
    } else {
      //printnt('First time user: showing onboarding');
      Get.offAllNamed(AppRoutes.onboarding);
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
                'Smart Campus',
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
                'Track attendance with ease',
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
