import 'package:attedance__/features/authentication/controllers/controllers_onboarding/onboarding_controller.dart';
import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/device/device_utility.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Positioned(
      bottom: DeviceUtility.getBottomNavigationBarHeight(),
      right: TSizes.defaultSpace,
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),

          backgroundColor: dark ? TColors.white : TColors.white,
          // side: BorderSide(color: dark ? TColors.white : TColors.buttonPrimary),
        ),
        child: Icon(
          Iconsax.arrow_right_3,
          color: dark ? TColors.yellow : TColors.deepPurple,
        ),
      ),
    );
  }
}
