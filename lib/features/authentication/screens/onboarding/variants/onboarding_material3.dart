import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../../common/utils/constants/image_strings.dart';
import '../../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingMaterial3 extends StatelessWidget {
  const OnboardingMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              _buildM3Page(
                theme: theme,
                lottie: TImageStrings.hellorobo,
                title: 'Modern Campus',
                subtitle: 'Experience education through the lens of Material You.',
              ),
              _buildM3Page(
                theme: theme,
                image: TImageStrings.onboardingImage2,
                title: 'Fluid Tracking',
                subtitle: 'Adaptive attendance for every device in your classroom.',
              ),
              _buildM3Page(
                theme: theme,
                image: TImageStrings.onboardingImage3,
                title: 'Tonal Analytics',
                subtitle: 'Reports that harmonize with your institutional identity.',
              ),
            ],
          ),
          _buildM3Skip(controller, theme),
          _buildM3Navigation(controller, theme),
          _buildM3Next(controller, theme),
        ],
      ),
    );
  }

  Widget _buildM3Page({required ThemeData theme, String? lottie, String? image, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(48)),
            child: lottie != null ? Lottie.asset(lottie, width: 180) : Image.asset(image!, width: 180),
          ),
          const SizedBox(height: 64),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildM3Skip(OnboardingController controller, ThemeData theme) {
    return Positioned(
      top: 64,
      right: 24,
      child: TextButton(
        onPressed: () => controller.skipPage(),
        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
        child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildM3Navigation(OnboardingController controller, ThemeData theme) {
    return Positioned(
      bottom: 64,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: controller.currentPageIndex.value == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: controller.currentPageIndex.value == index ? theme.colorScheme.primary : theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4)),
          )),
        )),
      ),
    );
  }

  Widget _buildM3Next(OnboardingController controller, ThemeData theme) {
    return Positioned(
      bottom: 48,
      right: 32,
      child: FloatingActionButton.large(
        onPressed: () => controller.nextPage(),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
