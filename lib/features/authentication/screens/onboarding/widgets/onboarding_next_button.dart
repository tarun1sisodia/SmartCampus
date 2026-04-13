import 'package:flutter/material.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/common/utils/constants/sized.dart';
import 'package:smart_campus/common/utils/device/device_utility.dart';
import 'package:smart_campus/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: TSizes.defaultSpace,
      bottom: DeviceUtility.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Sharp edges
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: TColors.executiveNavy,
        ),
        child: const Text('NEXT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
      ),
    );
  }
}
