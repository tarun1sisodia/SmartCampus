import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/utils/constants/sized.dart';
import '../../../../common/utils/constants/text_strings.dart';
import 'singup_widgets/signup_form.dart';

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
