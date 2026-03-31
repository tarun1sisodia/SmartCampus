import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_reports_controller.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../../../common/ui_patterns/ui_style.dart';
import 'variants/reports/attendance_reports_corporate.dart';
import 'variants/reports/attendance_reports_minimalist.dart';
import 'variants/reports/attendance_reports_glassmorphism.dart';
import 'variants/reports/attendance_reports_neumorphic.dart';
import 'variants/reports/attendance_reports_material3.dart';
import 'variants/reports/attendance_reports_cupertino.dart';
import 'variants/reports/attendance_reports_cyberpunk.dart';
import 'variants/reports/attendance_reports_brutalist.dart';
import 'variants/reports/attendance_reports_academic.dart';
import 'variants/reports/attendance_reports_fluent.dart';

class AttendanceReportsScreen extends StatelessWidget {
  final reportsController = Get.put(AttendanceReportsController());

  AttendanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      
      return PatternScaffold(
        title: 'ATTENDANCE REPORTS',
        actions: [
          IconButton(
            onPressed: () => reportsController.loadAttendanceData(),
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => reportsController.exportAttendanceReport(),
            icon: const Icon(Iconsax.export),
            tooltip: 'Export Report',
          ),
        ],
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return AttendanceReportsCorporate(controller: reportsController);
      case UIStyle.softMinimalist:
        return AttendanceReportsMinimalist(controller: reportsController);
      case UIStyle.glassmorphism:
        return AttendanceReportsGlassmorphism(controller: reportsController);
      case UIStyle.neumorphism:
        return AttendanceReportsNeumorphism(controller: reportsController);
      case UIStyle.material3:
        return AttendanceReportsMaterial3(controller: reportsController);
      case UIStyle.cupertinoPro:
        return AttendanceReportsCupertino(controller: reportsController);
      case UIStyle.cyberpunkNeon:
        return AttendanceReportsCyberpunk(controller: reportsController);
      case UIStyle.brutalistBold:
        return AttendanceReportsBrutalist(controller: reportsController);
      case UIStyle.academicClassic:
        return AttendanceReportsAcademic(controller: reportsController);
      case UIStyle.fluentLayered:
        return AttendanceReportsFluent(controller: reportsController);
    }
  }
}
