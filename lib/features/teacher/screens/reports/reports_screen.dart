import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../controllers/attendance_reports_controller.dart';
import 'variants/reports/reports_corporate.dart';
import 'variants/reports/reports_minimalist.dart';
import 'variants/reports/reports_glassmorphism.dart';
import 'variants/reports/reports_neumorphism.dart';
import 'variants/reports/reports_material3.dart';
import 'variants/reports/reports_cupertino.dart';
import 'variants/reports/reports_cyberpunk.dart';
import 'variants/reports/reports_brutalist.dart';
import 'variants/reports/reports_academic.dart';
import 'variants/reports/reports_fluent.dart';

class ReportsScreen extends StatelessWidget {
  final reportsController = Get.put(AttendanceReportsController());

  ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'REPORTS_CENTER',
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const ReportsCorporate();
      case UIStyle.softMinimalist:
        return const ReportsMinimalist();
      case UIStyle.glassmorphism:
        return const ReportsGlassmorphism();
      case UIStyle.neumorphism:
        return const ReportsNeumorphism();
      case UIStyle.material3:
        return const ReportsMaterial3();
      case UIStyle.cupertinoPro:
        return const ReportsCupertino();
      case UIStyle.cyberpunkNeon:
        return const ReportsCyberpunk();
      case UIStyle.brutalistBold:
        return const ReportsBrutalist();
      case UIStyle.academicClassic:
        return const ReportsAcademic();
      case UIStyle.fluentLayered:
        return const ReportsFluent();
    }
  }
}
