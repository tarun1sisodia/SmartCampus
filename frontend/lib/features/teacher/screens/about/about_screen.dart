import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/about_brutalist.dart';
import 'variants/about_cupertino.dart';
import 'variants/about_fluent.dart';
import 'variants/about_material3.dart';
import 'variants/about_neumorphism.dart';
import 'variants/about_academic.dart';
import 'variants/about_corporate.dart';
import 'variants/about_cyberpunk.dart';
import 'variants/about_glassmorphism.dart';
import 'variants/about_minimalist.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'ABOUT_SYSTEM',
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const AboutCorporate();
      case UIStyle.softMinimalist:
        return const AboutMinimalist();
      case UIStyle.glassmorphism:
        return const AboutGlassmorphism();
      case UIStyle.neumorphism:
        return const AboutNeumorphism();
      case UIStyle.material3:
        return const AboutMaterial3();
      case UIStyle.cupertinoPro:
        return const AboutCupertino();
      case UIStyle.cyberpunkNeon:
        return const AboutCyberpunk();
      case UIStyle.brutalistBold:
        return const AboutBrutalist();
      case UIStyle.academicClassic:
        return const AboutAcademic();
      case UIStyle.fluentLayered:
        return const AboutFluent();
    }
  }
}
