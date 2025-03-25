import '../../controllers/controllers_onboarding/onboarding_controller.dart';
import 'widgets/onboarding_dot_navigation.dart';
import 'widgets/onboarding_next_button.dart';
import 'widgets/onboarding_skip.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/helper_function.dart';
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
                TImageStrings.hello_robo,
                width: THelperFunction.screenWidth() * 0.6,
              ),
              Lottie.asset(
                // TTexts.onboardingtitle3,
                TImageStrings.searching,
                width: THelperFunction.screenWidth() * 0.6,
              ),

              // OnboardingPage(
              //   image: TImageStrings.searching,
              //   title: TTexts.attedancetitle3,
              //   subtitle: TTexts.attendanceSubtitle3,
              // ),
              Lottie.asset(
                // TTexts.onboardingtitle3,
                TImageStrings.lightEmailSuccess,
                width: THelperFunction.screenWidth() * 0.6,
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
