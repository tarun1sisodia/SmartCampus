import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/device/device_utility.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import '../../../controllers/controllers_onboarding/onboarding_controller.dart';

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final controller = OnboardingController.instance;

    return Positioned(
      bottom: DeviceUtility.getBottomNavigationBarHeight() + 25,
      right: TSizes.defaultSpace,
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: controller.currentPageIndex.value == 2 ? 120 : 60,
          height: 60,
          child: ElevatedButton(
            onPressed: () => controller.nextPage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.buttonPrimary : TColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
              shadowColor: dark
                  ? TColors.buttonPrimary.withOpacity(0.5)
                  : TColors.primary.withOpacity(0.5),
              padding: const EdgeInsets.all(0),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.currentPageIndex.value == 2)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Get Started',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: TColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  Icon(
                    controller.currentPageIndex.value == 2
                        ? Iconsax.login
                        : Iconsax.arrow_right_3,
                    color: TColors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
