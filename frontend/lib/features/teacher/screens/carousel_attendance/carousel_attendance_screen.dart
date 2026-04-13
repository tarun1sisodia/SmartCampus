import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_campus/common/ui_patterns/pattern_scaffold.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/ui_patterns/ui_style_controller.dart';
import 'package:smart_campus/features/teacher/controllers/carousel_attendance_controller.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_corporate.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_minimalist.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_glassmorphism.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_neumorphism.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_material3.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_cupertino.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_cyberpunk.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_brutalist.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_academic.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/variants/carousel_fluent.dart';

class CarouselAttendanceScreen extends StatelessWidget {
  CarouselAttendanceScreen({super.key});

  final carouselAttendanceController = Get.put(CarouselAttendanceController());

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'SWIFT_ATTENDANCE',
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const CarouselCorporate();
      case UIStyle.softMinimalist:
        return const CarouselMinimalist();
      case UIStyle.glassmorphism:
        return const CarouselGlassmorphism();
      case UIStyle.neumorphism:
        return const CarouselNeumorphism();
      case UIStyle.material3:
        return const CarouselMaterial3();
      case UIStyle.cupertinoPro:
        return const CarouselCupertino();
      case UIStyle.cyberpunkNeon:
        return const CarouselCyberpunk();
      case UIStyle.brutalistBold:
        return const CarouselBrutalist();
      case UIStyle.academicClassic:
        return const CarouselAcademic();
      case UIStyle.fluentLayered:
        return const CarouselFluent();
    }
  }
}
