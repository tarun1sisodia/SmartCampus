import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/import_data/import_corporate.dart';
import 'variants/import_data/import_minimalist.dart';
import 'variants/import_data/import_glassmorphism.dart';
import 'variants/import_data/import_neumorphism.dart';
import 'variants/import_data/import_material3.dart';
import 'variants/import_data/import_cupertino.dart';
import 'variants/import_data/import_cyberpunk.dart';
import 'variants/import_data/import_brutalist.dart';
import 'variants/import_data/import_academic.dart';
import 'variants/import_data/import_fluent.dart';

class ImportDataScreen extends StatelessWidget {
  const ImportDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'IMPORT_DATA',
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const ImportCorporate();
      case UIStyle.softMinimalist:
        return const ImportMinimalist();
      case UIStyle.glassmorphism:
        return const ImportGlassmorphism();
      case UIStyle.neumorphism:
        return const ImportNeumorphism();
      case UIStyle.material3:
        return const ImportMaterial3();
      case UIStyle.cupertinoPro:
        return const ImportCupertino();
      case UIStyle.cyberpunkNeon:
        return const ImportCyberpunk();
      case UIStyle.brutalistBold:
        return const ImportBrutalist();
      case UIStyle.academicClassic:
        return const ImportAcademic();
      case UIStyle.fluentLayered:
        return const ImportFluent();
    }
  }
}
