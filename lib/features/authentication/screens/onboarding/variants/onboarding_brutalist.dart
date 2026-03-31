import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingBrutalist extends StatelessWidget {
  const OnboardingBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildBrutalPage(
                lottie: TImageStrings.hellorobo,
                title: 'RAW_POWER',
                subtitle: 'Attendance tracking with maximum impact.',
                color: yellow,
              ),
              _buildBrutalPage(
                image: TImageStrings.onboardingImage2,
                title: 'BOLD_INTERACT',
                subtitle: 'No soft edges. Just pure functionality.',
                color: orange,
              ),
              _buildBrutalPage(
                image: TImageStrings.onboardingImage3,
                title: 'DATA_DRIVE',
                subtitle: 'Institutional reports with brutalist clarity.',
                color: blue,
              ),
            ],
          ),
          _buildBrutalSkip(controller),
          _buildBrutalNavigation(controller),
          _buildBrutalNext(controller),
        ],
      ),
    );
  }

  Widget _buildBrutalPage({String? lottie, String? image, required String title, required String subtitle, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [BoxShadow(color: color, offset: const Offset(12, 12))],
            ),
            child: lottie != null ? Lottie.asset(lottie, width: 140) : Image.asset(image!, width: 140),
          ),
          const SizedBox(height: 64),
          _stackText(title, color, fontSize: 40),
          const SizedBox(height: 16),
          _brutalSubtitle(subtitle),
        ],
      ),
    );
  }

  Widget _stackText(String text, Color color, {double fontSize = 40}) {
    return Stack(
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1, foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = Colors.black)),
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1)),
      ],
    );
  }

  Widget _brutalSubtitle(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black, width: 2)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
    );
  }

  Widget _buildBrutalSkip(OnboardingController controller) {
    return Positioned(
      top: 64,
      right: 24,
      child: GestureDetector(
        onTap: () => controller.skipPage(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
          child: const Text('SKIP', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _buildBrutalNavigation(OnboardingController controller) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: controller.currentPageIndex.value == index ? const Color(0xFFFFE14D) : Colors.white,
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: controller.currentPageIndex.value == index ? [const BoxShadow(color: Colors.black, offset: Offset(4, 4))] : null,
            ),
          )),
        )),
      ),
    );
  }

  Widget _buildBrutalNext(OnboardingController controller) {
    return Positioned(
      bottom: 48,
      right: 24,
      child: GestureDetector(
        onTap: () => controller.nextPage(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFFF8C42), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))]),
          child: const Icon(Icons.arrow_forward, color: Colors.black, size: 28),
        ),
      ),
    );
  }
}
