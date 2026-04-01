import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/help_corporate.dart';
import 'variants/help_minimalist.dart';
import 'variants/help_glassmorphism.dart';
import 'variants/help_neumorphism.dart';
import 'variants/help_material3.dart';
import 'variants/help_cupertino.dart';
import 'variants/help_cyberpunk.dart';
import 'variants/help_brutalist.dart';
import 'variants/help_academic.dart';
import 'variants/help_fluent.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'HELP_AND_SUPPORT',
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const HelpCorporate();
      case UIStyle.softMinimalist:
        return const HelpMinimalist();
      case UIStyle.glassmorphism:
        return const HelpGlassmorphism();
      case UIStyle.neumorphism:
        return const HelpNeumorphism();
      case UIStyle.material3:
        return const HelpMaterial3();
      case UIStyle.cupertinoPro:
        return const HelpCupertino();
      case UIStyle.cyberpunkNeon:
        return const HelpCyberpunk();
      case UIStyle.brutalistBold:
        return const HelpBrutalist();
      case UIStyle.academicClassic:
        return const HelpAcademic();
      case UIStyle.fluentLayered:
        return const HelpFluent();
    }
  }
}
