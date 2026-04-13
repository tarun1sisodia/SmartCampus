import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../controllers/login_controller.dart';
import 'variants/login_academic.dart';
import 'variants/login_brutalist.dart';
import 'variants/login_corporate.dart';
import 'variants/login_cupertino.dart';
import 'variants/login_cyberpunk.dart';
import 'variants/login_fluent.dart';
import 'variants/login_glassmorphism.dart';
import 'variants/login_material3.dart';
import 'variants/login_minimalist.dart';
import 'variants/login_neumorphism.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final controller = Get.put(LoginController());

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
        return const LoginCorporate();
      case UIStyle.softMinimalist:
        return const LoginMinimalist();
      case UIStyle.glassmorphism:
        return const LoginGlassmorphism();
      case UIStyle.neumorphism:
        return const LoginNeumorphism();
      case UIStyle.material3:
        return const LoginMaterial3();
      case UIStyle.cupertinoPro:
        return const LoginCupertino();
      case UIStyle.cyberpunkNeon:
        return const LoginCyberpunk();
      case UIStyle.brutalistBold:
        return const LoginBrutalist();
      case UIStyle.academicClassic:
        return const LoginAcademic();
      case UIStyle.fluentLayered:
        return const LoginFluent();
    }
  }
}
