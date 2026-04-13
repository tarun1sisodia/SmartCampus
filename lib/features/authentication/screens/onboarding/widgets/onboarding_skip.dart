import 'package:flutter/material.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/common/utils/constants/sized.dart';
import 'package:smart_campus/common/utils/device/device_utility.dart';
import 'package:smart_campus/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingSkip extends StatelessWidget {
  const OnboardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: DeviceUtility.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnboardingController.instance.skipPage(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: TColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: TColors.slate400, width: 1.5),
          ),
        ),
        child: const Text(
          'SKIP',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.0,
            color: TColors.slate900,
          ),
        ),
      ),
    );
  }
}
