import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingMinimalist extends StatelessWidget {
  const OnboardingMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildMinimalPage(
                lottie: TImageStrings.hellorobo,
                title: 'Simple Registration',
                subtitle: 'Effortless attendance tracking for the modern educator.',
              ),
              _buildMinimalPage(
                image: TImageStrings.onboardingImage2,
                title: 'Clean Interface',
                subtitle: 'Focused on what matters most in your classroom.',
              ),
              _buildMinimalPage(
                image: TImageStrings.onboardingImage3,
                title: 'Smart Analytics',
                subtitle: 'Insightful reports delivered with minimalist elegance.',
              ),
            ],
          ),
          _buildMinimalSkip(controller),
          _buildMinimalNavigation(controller),
          _buildMinimalNext(controller),
        ],
      ),
    );
  }

  Widget _buildMinimalPage({String? lottie, String? image, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottie != null) Lottie.asset(lottie, width: 220),
          if (image != null) Image.asset(image, width: 220),
          const SizedBox(height: 64),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: Colors.black87, letterSpacing: -1)),
          const SizedBox(height: 24),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black38, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildMinimalSkip(OnboardingController controller) {
    return Positioned(
      top: 64,
      right: 32,
      child: TextButton(
        onPressed: () => controller.skipPage(),
        child: const Text('Skip', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.normal, fontSize: 13)),
      ),
    );
  }

  Widget _buildMinimalNavigation(OnboardingController controller) {
    return Positioned(
      bottom: 64,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: controller.currentPageIndex.value == index ? Colors.black87 : Colors.black12, shape: BoxShape.circle),
          )),
        )),
      ),
    );
  }

  Widget _buildMinimalNext(OnboardingController controller) {
    return Positioned(
      bottom: 48,
      right: 32,
      child: IconButton(
        onPressed: () => controller.nextPage(),
        icon: const Icon(Icons.arrow_forward, color: Colors.black38, size: 24),
      ),
    );
  }
}
