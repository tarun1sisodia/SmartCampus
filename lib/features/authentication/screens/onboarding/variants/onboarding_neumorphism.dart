import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingNeumorphism extends StatelessWidget {
  const OnboardingNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    const bgColor = Color(0xFFE0E5EC);

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildNeuPage(
                lottie: TImageStrings.hellorobo,
                title: 'Tactile Learning',
                subtitle: 'Soft surfaces meet pedagogical precision.',
                bgColor: bgColor,
              ),
              _buildNeuPage(
                image: TImageStrings.onboardingImage2,
                title: 'Inset Registry',
                subtitle: 'A deeper way to manage your students.',
                bgColor: bgColor,
              ),
              _buildNeuPage(
                image: TImageStrings.onboardingImage3,
                title: 'Depth Analytics',
                subtitle: 'Subtle shadows, powerful insights.',
                bgColor: bgColor,
              ),
            ],
          ),
          _buildNeuSkip(controller, bgColor),
          _buildNeuNavigation(controller, bgColor),
          _buildNeuNext(controller, bgColor),
        ],
      ),
    );
  }

  Widget _buildNeuPage({String? lottie, String? image, required String title, required String subtitle, required Color bgColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottie != null) _neuImageContainer(lottie: lottie, bgColor: bgColor),
          if (image != null) _neuImageContainer(image: image, bgColor: bgColor),
          const SizedBox(height: 64),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Color(0xFF4D565F), letterSpacing: -1)),
          const SizedBox(height: 24),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFA3B1C6), height: 1.6, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _neuImageContainer({String? lottie, String? image, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(10, 10), blurRadius: 20),
        ],
      ),
      child: lottie != null ? Lottie.asset(lottie, width: 140) : Image.asset(image!, width: 140),
    );
  }

  Widget _buildNeuSkip(OnboardingController controller, Color bgColor) {
    return Positioned(
      top: 64,
      right: 24,
      child: GestureDetector(
        onTap: () => controller.skipPage(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 8),
            ],
          ),
          child: const Text('Skip', style: TextStyle(color: Color(0xFF4D565F), fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildNeuNavigation(OnboardingController controller, Color bgColor) {
    return Positioned(
      bottom: 64,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: controller.currentPageIndex.value == index),
                BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: controller.currentPageIndex.value == index),
              ],
            ),
          )),
        )),
      ),
    );
  }

  Widget _buildNeuNext(OnboardingController controller, Color bgColor) {
    return Positioned(
      bottom: 48,
      right: 32,
      child: GestureDetector(
        onTap: () => controller.nextPage(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
            ],
          ),
          child: const Icon(Icons.arrow_forward, color: Color(0xFF4D565F), size: 32),
        ),
      ),
    );
  }
}
