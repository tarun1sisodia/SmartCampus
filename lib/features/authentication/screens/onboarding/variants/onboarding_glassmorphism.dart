import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingGlassmorphism extends StatelessWidget {
  const OnboardingGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildGlassPage(
                lottie: TImageStrings.hellorobo,
                title: 'Future of Campus',
                subtitle: 'Intelligence redefined with glassmorphism.',
              ),
              _buildGlassPage(
                image: TImageStrings.onboardingImage2,
                title: 'Ethereal Tracking',
                subtitle: 'Vibrant visuals meet pedagogical precision.',
              ),
              _buildGlassPage(
                image: TImageStrings.onboardingImage3,
                title: 'Crystal Analytics',
                subtitle: 'Clarity in every report across the institution.',
              ),
            ],
          ),
          _buildGlassSkip(controller),
          _buildGlassNavigation(controller),
          _buildGlassNext(controller),
        ],
      ),
    );
  }

  Widget _buildGlassPage({String? lottie, String? image, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: _glassContainer(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lottie != null) Lottie.asset(lottie, width: 220),
              if (image != null) Image.asset(image, width: 220),
              const SizedBox(height: 48),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white, letterSpacing: -1)),
              const SizedBox(height: 16),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white70, height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSkip(OnboardingController controller) {
    return Positioned(
      top: 64,
      right: 32,
      child: _glassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextButton(
          onPressed: () => controller.skipPage(),
          child: const Text('Skip', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildGlassNavigation(OnboardingController controller) {
    return Positioned(
      bottom: 64,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(color: controller.currentPageIndex.value == index ? Colors.white : Colors.white24, shape: BoxShape.circle),
          )),
        )),
      ),
    );
  }

  Widget _buildGlassNext(OnboardingController controller) {
    return Positioned(
      bottom: 48,
      right: 32,
      child: GestureDetector(
        onTap: () => controller.nextPage(),
        child: _glassContainer(
          padding: const EdgeInsets.all(16),
          child: const Icon(Icons.arrow_forward, color: Colors.white70, size: 24),
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
