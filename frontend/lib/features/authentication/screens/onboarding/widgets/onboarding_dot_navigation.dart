import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/common/utils/constants/sized.dart';
import 'package:smart_campus/common/utils/device/device_utility.dart';
import 'package:smart_campus/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingDotNavigation extends StatelessWidget {
  const OnboardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;

    return Positioned(
      bottom: DeviceUtility.getBottomNavigationBarHeight() + 25,
      left: TSizes.defaultSpace,
      child: SmoothPageIndicator(
        count: 3,
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        effect: const ExpandingDotsEffect(
          activeDotColor: TColors.executiveNavy,
          dotColor: TColors.slate300,
          dotHeight: 8,
          dotWidth: 8,
          expansionFactor: 4,
          spacing: 8,
          // Sharp edges (Fixed radius)
          radius: 2,
        ),
      ),
    );
  }
}
