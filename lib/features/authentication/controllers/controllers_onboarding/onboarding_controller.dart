import 'package:smart_campus/app/routes/app_routes.dart';
import 'package:smart_campus/common/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/storage_service.dart';
import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();
  final pageController = PageController();
  final currentPageIndex = 0.obs;

  void updatePageIndicator(index) {
    ///print('Updating page indicator to index: $index');
    currentPageIndex.value = index;
  }

  void dotNavigationClick(index) {
    ///print('Dot navigation clicked, navigating to index: $index');
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if (currentPageIndex.value == 2) {
      // Mark onboarding as completed
      StorageService.instance.setOnboardingStatus(true);

      // Show welcome message
      TSnackBar.showSuccess(
        message: TTexts.allset,
        title: TTexts.setupComplete,
      );

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    // Mark onboarding as completed
    StorageService.instance.setOnboardingStatus(true);

    // Show welcome message
    TSnackBar.showInfo(
        message: TTexts.welcomeSkipOnboarding, title: TTexts.welcome);

    // Navigate to login, not directly to home
    Get.offAllNamed(AppRoutes.login);
  }

  void checkIfOnboardingCompleted() {
    ///print('Checking if onboarding is completed');
  }
}
