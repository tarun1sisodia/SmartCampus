import 'package:attedance__/routes/app_routes.dart';

import '../../screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/storage_service.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();
  final pageController = PageController();
  final currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if (currentPageIndex.value == 2) {
      // Mark onboarding as completed
      StorageService.instance.setOnboardingStatus(true);
      Get.offAllNamed(AppRoutes.login); // Fixed route
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    // Mark onboarding as completed
    StorageService.instance.setOnboardingStatus(true);
    Get.offAllNamed(AppRoutes.login); // Fixed route
  }

  @override
  void onInit() {
    super.onInit();
  }

  void checkIfOnboardingCompleted() {}
}
