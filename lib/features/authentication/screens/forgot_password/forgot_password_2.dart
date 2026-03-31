import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../controllers/controllers_forgot_password/forgot_password_controller.dart';
import 'variants/forgot_password_academic.dart';
import 'variants/forgot_password_brutalist.dart';
import 'variants/forgot_password_corporate.dart';
import 'variants/forgot_password_cupertino.dart';
import 'variants/forgot_password_cyberpunk.dart';
import 'variants/forgot_password_fluent.dart';
import 'variants/forgot_password_glassmorphism.dart';
import 'variants/forgot_password_material3.dart';
import 'variants/forgot_password_minimalist.dart';
import 'variants/forgot_password_neumorphism.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final controller = Get.put(ForgotPasswordController());

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
        return const ForgotPasswordCorporate();
      case UIStyle.softMinimalist:
        return const ForgotPasswordMinimalist();
      case UIStyle.glassmorphism:
        return const ForgotPasswordGlassmorphism();
      case UIStyle.neumorphism:
        return const ForgotPasswordNeumorphism();
      case UIStyle.material3:
        return const ForgotPasswordMaterial3();
      case UIStyle.cupertinoPro:
        return const ForgotPasswordCupertino();
      case UIStyle.cyberpunkNeon:
        return const ForgotPasswordCyberpunk();
      case UIStyle.brutalistBold:
        return const ForgotPasswordBrutalist();
      case UIStyle.academicClassic:
        return const ForgotPasswordAcademic();
      case UIStyle.fluentLayered:
        return const ForgotPasswordFluent();
    }
  }
}
