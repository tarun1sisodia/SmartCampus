import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../controllers/controllers_onboarding/onboarding_controller.dart';
import 'variants/onboarding_academic.dart';
import 'variants/onboarding_brutalist.dart';
import 'variants/onboarding_corporate.dart';
import 'variants/onboarding_cupertino.dart';
import 'variants/onboarding_cyberpunk.dart';
import 'variants/onboarding_fluent.dart';
import 'variants/onboarding_glassmorphism.dart';
import 'variants/onboarding_material3.dart';
import 'variants/onboarding_minimalist.dart';
import 'variants/onboarding_neumorphism.dart';

class Onboarding extends StatelessWidget {
  Onboarding({super.key});

  final controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      return Scaffold(
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const OnboardingCorporate();
      case UIStyle.softMinimalist:
        return const OnboardingMinimalist();
      case UIStyle.glassmorphism:
        return const OnboardingGlassmorphism();
      case UIStyle.neumorphism:
        return const OnboardingNeumorphism();
      case UIStyle.material3:
        return const OnboardingMaterial3();
      case UIStyle.cupertinoPro:
        return const OnboardingCupertino();
      case UIStyle.cyberpunkNeon:
        return const OnboardingCyberpunk();
      case UIStyle.brutalistBold:
        return const OnboardingBrutalist();
      case UIStyle.academicClassic:
        return const OnboardingAcademic();
      case UIStyle.fluentLayered:
        return const OnboardingFluent();
    }
  }
}
