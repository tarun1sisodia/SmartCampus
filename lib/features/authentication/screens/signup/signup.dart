import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../../controllers/signup_controller.dart';
import 'variants/signup_academic.dart';
import 'variants/signup_brutalist.dart';
import 'variants/signup_corporate.dart';
import 'variants/signup_cupertino.dart';
import 'variants/signup_cyberpunk.dart';
import 'variants/signup_fluent.dart';
import 'variants/signup_glassmorphism.dart';
import 'variants/signup_material3.dart';
import 'variants/signup_minimalist.dart';
import 'variants/signup_neumorphism.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
        return const SignupCorporate();
      case UIStyle.softMinimalist:
        return const SignupMinimalist();
      case UIStyle.glassmorphism:
        return const SignupGlassmorphism();
      case UIStyle.neumorphism:
        return const SignupNeumorphism();
      case UIStyle.material3:
        return const SignupMaterial3();
      case UIStyle.cupertinoPro:
        return const SignupCupertino();
      case UIStyle.cyberpunkNeon:
        return const SignupCyberpunk();
      case UIStyle.brutalistBold:
        return const SignupBrutalist();
      case UIStyle.academicClassic:
        return const SignupAcademic();
      case UIStyle.fluentLayered:
        return const SignupFluent();
    }
  }
}
