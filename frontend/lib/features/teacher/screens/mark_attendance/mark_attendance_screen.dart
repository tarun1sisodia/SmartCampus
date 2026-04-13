import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../../../common/utils/helpers/snackbar_helper.dart';
import '../../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import 'variants/mark_attendance_corporate.dart';
import 'variants/mark_attendance_minimalist.dart';
import 'variants/mark_attendance_glassmorphism.dart';
import 'variants/mark_attendance_neumorphic.dart';
import 'variants/mark_attendance_material3.dart';
import 'variants/mark_attendance_cupertino.dart';
import 'variants/mark_attendance_cyberpunk.dart';
import 'variants/mark_attendance_brutalist.dart';
import 'variants/mark_attendance_academic.dart';
import 'variants/mark_attendance_fluent.dart';

class MarkAttendanceScreen extends StatelessWidget {
  final attendanceController = Get.find<AttendanceController>();

  MarkAttendanceScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSessionStatus());
  }

  void _checkSessionStatus() {
    if (attendanceController.currentSessionId.value.isNotEmpty &&
        !attendanceController.isSessionRunning(attendanceController.currentSessionId.value)) {
      TSnackBar.showInfo(
        message: 'THIS SESSION IS CURRENTLY CLOSED. DATA CANNOT BE MODIFIED.',
        title: 'SESSION CLOSED',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      
      return PatternScaffold(
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return MarkAttendanceCorporate(controller: attendanceController);
      case UIStyle.softMinimalist:
        return MarkAttendanceMinimalist(controller: attendanceController);
      case UIStyle.glassmorphism:
        return MarkAttendanceGlassmorphism(controller: attendanceController);
      case UIStyle.neumorphism:
        return MarkAttendanceNeumorphic(controller: attendanceController);
      case UIStyle.material3:
        return MarkAttendanceMaterial3(controller: attendanceController);
      case UIStyle.cupertinoPro:
        return MarkAttendanceCupertino(controller: attendanceController);
      case UIStyle.cyberpunkNeon:
        return MarkAttendanceCyberpunk(controller: attendanceController);
      case UIStyle.brutalistBold:
        return MarkAttendanceBrutalist(controller: attendanceController);
      case UIStyle.academicClassic:
        return MarkAttendanceAcademic(controller: attendanceController);
      case UIStyle.fluentLayered:
        return MarkAttendanceFluent(controller: attendanceController);
    }
  }
}
