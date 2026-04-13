import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/common/ui_patterns/pattern_scaffold.dart';
import 'package:smart_campus/common/ui_patterns/ui_style_controller.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_corporate.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_minimalist.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_glassmorphism.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_neumorphic.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_material3.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_cupertino.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_cyberpunk.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_brutalist.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_academic.dart';
import 'package:smart_campus/features/teacher/screens/attendance/variants/attendance_fluent.dart';

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
