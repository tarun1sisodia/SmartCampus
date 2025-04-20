import 'package:attedance__/common/utils/constants/text_strings.dart';
import 'package:attedance__/features/authentication/screens/onboarding/widgets/onboarding_page.dart';

import '../../controllers/controllers_onboarding/onboarding_controller.dart';
import 'widgets/onboarding_dot_navigation.dart';
import 'widgets/onboarding_next_button.dart';
import 'widgets/onboarding_skip.dart';
import '../../../../common/utils/constants/image_strings.dart';
import '../../../../common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class Onboarding extends StatelessWidget {
  Onboarding({super.key});

  final controller = Get.put(OnboardingController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Horizontal Page Scrroll
          PageView(
            //to know which page is currently visible.
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              Lottie.asset(
                // TTexts.onboardingtitle3,
                TImageStrings.hellorobo,
                width: THelperFunction.screenWidth() * 0.6,
              ),
              OnboardingPage(
                image: TImageStrings.onboardingImage2,
                title: TTexts.attedancetitle2,
                subtitle: TTexts.attendanceSubtitle2,
              ),
              OnboardingPage(
                image: TImageStrings.onboardingImage3,
                title: TTexts.attedancetitle3,
                subtitle: TTexts.attendanceSubtitle3,
              ),
            ],
          ),

          //Skip Button
          OnboardingSkip(),

          //Novigation Bar dots
          OnboardingDotNavigation(),
          OnboardingNextButton(),
        ],
      ),
    );
  }
}
