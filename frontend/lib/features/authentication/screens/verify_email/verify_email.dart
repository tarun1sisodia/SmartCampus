import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/verify_email_academic.dart';
import 'variants/verify_email_brutalist.dart';
import 'variants/verify_email_corporate.dart';
import 'variants/verify_email_cupertino.dart';
import 'variants/verify_email_cyberpunk.dart';
import 'variants/verify_email_fluent.dart';
import 'variants/verify_email_glassmorphism.dart';
import 'variants/verify_email_material3.dart';
import 'variants/verify_email_minimalist.dart';
import 'variants/verify_email_neumorphism.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

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
        return VerifyEmailCorporate(email: email);
      case UIStyle.softMinimalist:
        return VerifyEmailMinimalist(email: email);
      case UIStyle.glassmorphism:
        return VerifyEmailGlassmorphism(email: email);
      case UIStyle.neumorphism:
        return VerifyEmailNeumorphism(email: email);
      case UIStyle.material3:
        return VerifyEmailMaterial3(email: email);
      case UIStyle.cupertinoPro:
        return VerifyEmailCupertino(email: email);
      case UIStyle.cyberpunkNeon:
        return VerifyEmailCyberpunk(email: email);
      case UIStyle.brutalistBold:
        return VerifyEmailBrutalist(email: email);
      case UIStyle.academicClassic:
        return VerifyEmailAcademic(email: email);
      case UIStyle.fluentLayered:
        return VerifyEmailFluent(email: email);
    }
  }
}
