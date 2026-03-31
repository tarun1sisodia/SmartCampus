import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../controllers/carousel_attendance_controller.dart';
import 'variants/carousel_attendance/carousel_corporate.dart';
import 'variants/carousel_attendance/carousel_minimalist.dart';
import 'variants/carousel_attendance/carousel_glassmorphism.dart';
import 'variants/carousel_attendance/carousel_neumorphism.dart';
import 'variants/carousel_attendance/carousel_material3.dart';
import 'variants/carousel_attendance/carousel_cupertino.dart';
import 'variants/carousel_attendance/carousel_cyberpunk.dart';
import 'variants/carousel_attendance/carousel_brutalist.dart';
import 'variants/carousel_attendance/carousel_academic.dart';
import 'variants/carousel_attendance/carousel_fluent.dart';

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
