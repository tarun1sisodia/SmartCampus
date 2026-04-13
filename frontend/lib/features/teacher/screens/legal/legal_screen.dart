import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/legal_corporate.dart';
import 'variants/legal_minimalist.dart';
import 'variants/legal_glassmorphism.dart';
import 'variants/legal_neumorphism.dart';
import 'variants/legal_material3.dart';
import 'variants/legal_cupertino.dart';
import 'variants/legal_cyberpunk.dart';
import 'variants/legal_brutalist.dart';
import 'variants/legal_academic.dart';
import 'variants/legal_fluent.dart';

class LegalScreen extends StatelessWidget {
  final String initialSection;
  const LegalScreen({super.key, required this.initialSection});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'LEGAL_INFORMATION',
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return LegalCorporate(initialSection: initialSection);
      case UIStyle.softMinimalist:
        return LegalMinimalist(initialSection: initialSection);
      case UIStyle.glassmorphism:
        return LegalGlassmorphism(initialSection: initialSection);
      case UIStyle.neumorphism:
        return LegalNeumorphism(initialSection: initialSection);
      case UIStyle.material3:
        return LegalMaterial3(initialSection: initialSection);
      case UIStyle.cupertinoPro:
        return LegalCupertino(initialSection: initialSection);
      case UIStyle.cyberpunkNeon:
        return LegalCyberpunk(initialSection: initialSection);
      case UIStyle.brutalistBold:
        return LegalBrutalist(initialSection: initialSection);
      case UIStyle.academicClassic:
        return LegalAcademic(initialSection: initialSection);
      case UIStyle.fluentLayered:
        return LegalFluent(initialSection: initialSection);
    }
  }
}
