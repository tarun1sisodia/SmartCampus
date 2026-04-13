import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../../common/utils/constants/image_strings.dart';
import '../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingCorporate extends StatelessWidget {
  const OnboardingCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildCorporatePage(
                lottie: TImageStrings.hellorobo,
                title: 'SYSTEM_INITIALIZATION',
                subtitle: 'ESTABLISHING_SECURE_CAMPUS_PROTOCOLS',
              ),
              _buildCorporatePage(
                image: TImageStrings.onboardingImage2,
                title: 'ATTENDANCE_LOGISTICS',
                subtitle: 'STREAMLINED_REGISTRY_MANAGEMENT_V.1.0',
              ),
              _buildCorporatePage(
                image: TImageStrings.onboardingImage3,
                title: 'INSTITUTIONAL_ANALYTICS',
                subtitle: 'DATA_DRIVEN_CAMPUS_ADMINISTRATION',
              ),
            ],
          ),
          _buildCorporateSkip(controller),
          _buildCorporateNavigation(controller),
          _buildCorporateNext(controller),
        ],
      ),
    );
  }

  Widget _buildCorporatePage({String? lottie, String? image, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottie != null) Lottie.asset(lottie, width: 220),
          if (image != null) Image.asset(image, width: 220),
          const SizedBox(height: 64),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFF0F172A), width: 4))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Text(subtitle.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateSkip(OnboardingController controller) {
    return Positioned(
      top: 64,
      right: 24,
      child: TextButton(
        onPressed: () => controller.skipPage(),
        child: const Text('SKIP_WALKTHROUGH', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildCorporateNavigation(OnboardingController controller) {
    return Positioned(
      bottom: 64,
      left: 24,
      child: Obx(() => Row(
        children: List.generate(3, (index) => Container(
          width: controller.currentPageIndex.value == index ? 40 : 12,
          height: 6,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: controller.currentPageIndex.value == index ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1), borderRadius: BorderRadius.zero),
        )),
      )),
    );
  }

  Widget _buildCorporateNext(OnboardingController controller) {
    return Positioned(
      bottom: 48,
      right: 24,
      child: InkWell(
        onTap: () => controller.nextPage(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: const Color(0xFF64748B), width: 1)),
          child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
