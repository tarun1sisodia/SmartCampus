import 'package:flutter/material.dart';

import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/device/device_utility.dart';
import '../../../../../common/utils/helpers/helper_function.dart';
import '../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingSkip extends StatelessWidget {
  const OnboardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Positioned(
      top: DeviceUtility.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.skipPage(),
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? Colors.black54 : Colors.white,
          foregroundColor: dark ? TColors.white : TColors.primary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.buttonRadius),
            side: BorderSide(
              color: dark ? Colors.white24 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.md,
            vertical: TSizes.sm,
          ),
        ),
        child: Text(
          'Skip',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: dark ? TColors.white : TColors.primary,
              ),
        ),
      ),
    );
  }
}
