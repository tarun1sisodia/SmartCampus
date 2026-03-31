import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingFluent extends StatelessWidget {
  const OnboardingFluent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    const fluentBg = Color(0xFFF3F3F3);

    return Container(
      color: fluentBg,
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildFluentPage(
                lottie: TImageStrings.hellorobo,
                title: 'Inclusive Experience',
                subtitle: 'A modern pedagogical platform designed for accessibility.',
              ),
              _buildFluentPage(
                image: TImageStrings.onboardingImage2,
                title: 'Layered Tracking',
                subtitle: 'Depth and clarity in every classroom interaction.',
              ),
              _buildFluentPage(
                image: TImageStrings.onboardingImage3,
                title: 'Fluent Analytics',
                subtitle: 'Insights that flow seamlessly across your institution.',
              ),
            ],
          ),
          _buildFluentSkip(controller),
          _buildFluentNavigation(controller),
          _buildFluentNext(controller),
        ],
      ),
    );
  }

  Widget _buildFluentPage({String? lottie, String? image, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: lottie != null ? Lottie.asset(lottie, width: 140) : Image.asset(image!, width: 140),
          ),
          const SizedBox(height: 64),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Color(0xFF605E5C), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFluentSkip(OnboardingController controller) {
    return Positioned(
      top: 64,
      right: 24,
      child: TextButton(
        onPressed: () => controller.skipPage(),
        child: const Text('Skip Walkthrough', style: TextStyle(color: Color(0xFF0078D4), fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  Widget _buildFluentNavigation(OnboardingController controller) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: controller.currentPageIndex.value == index ? 20 : 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: controller.currentPageIndex.value == index ? const Color(0xFF0078D4) : Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
          )),
        )),
      ),
    );
  }

  Widget _buildFluentNext(OnboardingController controller) {
    return Positioned(
      bottom: 64,
      left: 24,
      right: 24,
      child: ElevatedButton(
        onPressed: () => controller.nextPage(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0078D4),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text('System Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
