import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'confirmation_variants/reset_confirmation_academic.dart';
import 'confirmation_variants/reset_confirmation_brutalist.dart';
import 'confirmation_variants/reset_confirmation_corporate.dart';
import 'confirmation_variants/reset_confirmation_cupertino.dart';
import 'confirmation_variants/reset_confirmation_cyberpunk.dart';
import 'confirmation_variants/reset_confirmation_fluent.dart';
import 'confirmation_variants/reset_confirmation_glassmorphism.dart';
import 'confirmation_variants/reset_confirmation_material3.dart';
import 'confirmation_variants/reset_confirmation_minimalist.dart';
import 'confirmation_variants/reset_confirmation_neumorphism.dart';

class ResetPasswordConfirmation extends StatelessWidget {
  const ResetPasswordConfirmation({super.key, required this.email});

  final String email;

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
        return ResetConfirmationCorporate(email: email);
      case UIStyle.softMinimalist:
        return ResetConfirmationMinimalist(email: email);
      case UIStyle.glassmorphism:
        return ResetConfirmationGlassmorphism(email: email);
      case UIStyle.neumorphism:
        return ResetConfirmationNeumorphism(email: email);
      case UIStyle.material3:
        return ResetConfirmationMaterial3(email: email);
      case UIStyle.cupertinoPro:
        return ResetConfirmationCupertino(email: email);
      case UIStyle.cyberpunkNeon:
        return ResetConfirmationCyberpunk(email: email);
      case UIStyle.brutalistBold:
        return ResetConfirmationBrutalist(email: email);
      case UIStyle.academicClassic:
        return ResetConfirmationAcademic(email: email);
      case UIStyle.fluentLayered:
        return ResetConfirmationFluent(email: email);
    }
  }
}
