import 'package:attedance__/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/storage_service.dart';
import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();
  final pageController = PageController();
  final currentPageIndex = 0.obs;

  void updatePageIndicator(index) {
    ////print('Updating page indicator to index: $index');
    currentPageIndex.value = index;
  }

  void dotNavigationClick(index) {
    ////print('Dot navigation clicked, navigating to index: $index');
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if (currentPageIndex.value == 2) {
      ////print('Onboarding completed, navigating to login page');
      // Mark onboarding as completed
      StorageService.instance.setOnboardingStatus(true);
      
      // Show welcome message
      TSnackBar.showSuccess(
        message: 'You\'re all set! Let\'s get started with your attendance tracking.',
        title: 'Setup Complete',
      );
      
      Get.offAllNamed(AppRoutes.login);
    } else {
      int page = currentPageIndex.value + 1;
      ////print('Navigating to next page: $page');
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    ////print('Skipping onboarding, navigating to login page');
    // Mark onboarding as completed
    StorageService.instance.setOnboardingStatus(true);
    
    // Show welcome message
    TSnackBar.showInfo(
      message: 'Welcome to the Attendance App! Please log in to continue.',
      title: 'Welcome',
    );
    
    Get.offAllNamed(AppRoutes.login);
  }

  void checkIfOnboardingCompleted() {
    ////print('Checking if onboarding is completed');
  }
}