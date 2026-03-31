import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingCupertino extends StatelessWidget {
  const OnboardingCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildIosPage(
                lottie: TImageStrings.hellorobo,
                title: 'Elite Interface',
                subtitle: 'Precision designed for the modern teacher.',
              ),
              _buildIosPage(
                image: TImageStrings.onboardingImage2,
                title: 'Polished Tracking',
                subtitle: 'Seamlessly log attendance on any Apple device.',
              ),
              _buildIosPage(
                image: TImageStrings.onboardingImage3,
                title: 'iOS Analytics',
                subtitle: 'Graceful reporting at your fingertips.',
              ),
            ],
          ),
          _buildIosSkip(controller),
          _buildIosNavigation(controller),
          _buildIosNext(controller),
        ],
      ),
    );
  }

  Widget _buildIosPage({String? lottie, String? image, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottie != null) Lottie.asset(lottie, width: 220),
          if (image != null) Image.asset(image, width: 220),
          const SizedBox(height: 64),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: -1, color: Color(0xFF000000))),
          const SizedBox(height: 16),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93), height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildIosSkip(OnboardingController controller) {
    return Positioned(
      top: 64,
      right: 24,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => controller.skipPage(),
        child: const Text('Skip', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.normal, fontSize: 17)),
      ),
    );
  }

  Widget _buildIosNavigation(OnboardingController controller) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: controller.currentPageIndex.value == index ? const Color(0xFF000000) : const Color(0xFFD1D1D6), shape: BoxShape.circle),
          )),
        )),
      ),
    );
  }

  Widget _buildIosNext(OnboardingController controller) {
    return Positioned(
      bottom: 64,
      left: 24,
      right: 24,
      child: CupertinoButton.filled(
        borderRadius: BorderRadius.circular(14),
        onPressed: () => controller.nextPage(),
        child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
    );
  }
}
