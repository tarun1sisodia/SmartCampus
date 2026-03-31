import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingAcademic extends StatelessWidget {
  const OnboardingAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);

    return Container(
      color: paperColor,
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildScholarPage(
                lottie: TImageStrings.hellorobo,
                title: 'Classical Learning',
                subtitle: 'A formal introduction to modern pedagogical tools.',
                color: inkColor,
              ),
              _buildScholarPage(
                image: TImageStrings.onboardingImage2,
                title: 'Formal Registry',
                subtitle: 'Maintain institutional standards with every entry.',
                color: inkColor,
              ),
              _buildScholarPage(
                image: TImageStrings.onboardingImage3,
                title: 'Scholarly Insights',
                subtitle: 'Reports that reflect the weight of academic excellence.',
                color: inkColor,
              ),
            ],
          ),
          _buildScholarSkip(controller, inkColor),
          _buildScholarNavigation(controller, inkColor),
          _buildScholarNext(controller, inkColor),
        ],
      ),
    );
  }

  Widget _buildScholarPage({String? lottie, String? image, required String title, required String subtitle, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: color.withOpacity(0.05)), boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
            child: lottie != null ? Lottie.asset(lottie, width: 140) : Image.asset(image!, width: 140),
          ),
          const SizedBox(height: 64),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: color, letterSpacing: 0, fontFamily: 'Serif')),
          const SizedBox(height: 24),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: color.withOpacity(0.5), height: 1.6, letterSpacing: 0.5, fontFamily: 'Serif')),
        ],
      ),
    );
  }

  Widget _buildScholarSkip(OnboardingController controller, Color color) {
    return Positioned(
      top: 64,
      right: 32,
      child: TextButton(
        onPressed: () => controller.skipPage(),
        child: Text('Skip Protocol', style: TextStyle(color: color.withOpacity(0.4), fontWeight: FontWeight.normal, fontSize: 14, fontFamily: 'Serif')),
      ),
    );
  }

  Widget _buildScholarNavigation(OnboardingController controller, Color color) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(color: controller.currentPageIndex.value == index ? color : color.withOpacity(0.1), shape: BoxShape.circle),
          )),
        )),
      ),
    );
  }

  Widget _buildScholarNext(OnboardingController controller, Color color) {
    return Positioned(
      bottom: 48,
      right: 32,
      child: IconButton(
        onPressed: () => controller.nextPage(),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.05), border: Border.all(color: color.withOpacity(0.1)), shape: BoxShape.circle),
          child: Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.4), size: 20),
        ),
      ),
    );
  }
}
