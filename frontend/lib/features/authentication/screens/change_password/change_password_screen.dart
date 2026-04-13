import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/change_password_academic.dart';
import 'variants/change_password_brutalist.dart';
import 'variants/change_password_corporate.dart';
import 'variants/change_password_cupertino.dart';
import 'variants/change_password_cyberpunk.dart';
import 'variants/change_password_fluent.dart';
import 'variants/change_password_glassmorphism.dart';
import 'variants/change_password_material3.dart';
import 'variants/change_password_minimalist.dart';
import 'variants/change_password_neumorphism.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

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
        return const ChangePasswordCorporate();
      case UIStyle.softMinimalist:
        return const ChangePasswordMinimalist();
      case UIStyle.glassmorphism:
        return const ChangePasswordGlassmorphism();
      case UIStyle.neumorphism:
        return const ChangePasswordNeumorphism();
      case UIStyle.material3:
        return const ChangePasswordMaterial3();
      case UIStyle.cupertinoPro:
        return const ChangePasswordCupertino();
      case UIStyle.cyberpunkNeon:
        return const ChangePasswordCyberpunk();
      case UIStyle.brutalistBold:
        return const ChangePasswordBrutalist();
      case UIStyle.academicClassic:
        return const ChangePasswordAcademic();
      case UIStyle.fluentLayered:
        return const ChangePasswordFluent();
    }
  }
}
