import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/teacher_profile_controller.dart';
import 'widgets/biometric_overlay.dart';
import 'widgets/dashboard_shimmer.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/dashboard_minimalist.dart';
import 'variants/dashboard_neumorphic.dart';
import 'variants/dashboard_cupertino.dart';
import 'variants/dashboard_brutalist.dart';
import 'variants/dashboard_fluent.dart';
import '../../../../common/ui_patterns/pattern_scaffold.dart';

// DashboardScreen acts as a Switchboard for 10 distinct UI variants.
class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final dashboardController = Get.find<DashboardController>();
  final profileController = Get.put(TeacherProfileController());
  final uiController = UIStyleController.instance;
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (profileController.user.value == null) profileController.loadUserData();

    return PatternScaffold(
      body: Obx(() {
        // Security overlay handling
        if (!dashboardController.isAuthenticated.value &&
            dashboardController.biometricAuthService.isAvailable.value &&
            dashboardController.biometricAuthService.isBiometricEnabled.value &&
            !dashboardController.splashAuthenticationCompleted.value) {
          return Stack(
            children: [
              _buildSwitchboard(context),
              BiometricOverlay(
                dashboardController: dashboardController, 
                dark: Theme.of(context).brightness == Brightness.dark
              ),
            ],
          );
        }
        return _buildSwitchboard(context);
      }),
    );
  }

  Widget _buildSwitchboard(BuildContext context) {
    return Obx(() {
      if (dashboardController.isLoading.value) return DashboardShimmer(context: context);

      switch (uiController.currentStyle.value) {
        case UIStyle.industrialCorporate:
          return DashboardCorporate(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.softMinimalist:
          return DashboardMinimalist(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.glassmorphism:
          return DashboardGlassmorphism(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.neumorphism:
          return DashboardNeumorphic(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.material3:
          return DashboardMaterial3(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.cupertinoPro:
          return DashboardCupertino(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.cyberpunkNeon:
          return DashboardCyberpunk(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.brutalistBold:
          return DashboardBrutalist(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.academicClassic:
          return DashboardAcademic(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        case UIStyle.fluentLayered:
          return DashboardFluent(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
        default:
          return DashboardCorporate(
            dashboardController: dashboardController,
            profileController: profileController,
            searchController: searchController,
          );
      }
    });
  }
}
