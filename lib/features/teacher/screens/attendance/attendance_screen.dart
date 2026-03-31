import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../../../models/class_model.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../../../common/ui_patterns/ui_style.dart';
import 'variants/attendance/attendance_corporate.dart';
import 'variants/attendance/attendance_minimalist.dart';
import 'variants/attendance/attendance_glassmorphism.dart';
import 'variants/attendance/attendance_neumorphic.dart';
import 'variants/attendance/attendance_material3.dart';
import 'variants/attendance/attendance_cupertino.dart';
import 'variants/attendance/attendance_cyberpunk.dart';
import 'variants/attendance/attendance_brutalist.dart';
import 'variants/attendance/attendance_academic.dart';
import 'variants/attendance/attendance_fluent.dart';

class AttendanceScreen extends StatelessWidget {
  final ClassModel classModel;
  final attendanceController = Get.put(AttendanceController());

  AttendanceScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceController.setSelectedClass(classModel);
    });

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
        return AttendanceCorporate(classModel: classModel, controller: attendanceController);
      case UIStyle.softMinimalist:
        return AttendanceMinimalist(classModel: classModel, controller: attendanceController);
      case UIStyle.glassmorphism:
        return AttendanceGlassmorphism(classModel: classModel, controller: attendanceController);
      case UIStyle.neumorphism:
        return AttendanceNeumorphic(classModel: classModel, controller: attendanceController);
      case UIStyle.material3:
        return AttendanceMaterial3(classModel: classModel, controller: attendanceController);
      case UIStyle.cupertinoPro:
        return AttendanceCupertino(classModel: classModel, controller: attendanceController);
      case UIStyle.cyberpunkNeon:
        return AttendanceCyberpunk(classModel: classModel, controller: attendanceController);
      case UIStyle.brutalistBold:
        return AttendanceBrutalist(classModel: classModel, controller: attendanceController);
      case UIStyle.academicClassic:
        return AttendanceAcademic(classModel: classModel, controller: attendanceController);
      case UIStyle.fluentLayered:
        return AttendanceFluent(classModel: classModel, controller: attendanceController);
    }
  }
}
