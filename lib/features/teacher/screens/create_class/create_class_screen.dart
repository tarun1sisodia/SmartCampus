import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_campus/common/ui_patterns/pattern_scaffold.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/ui_patterns/ui_style_controller.dart';
import 'package:smart_campus/features/teacher/controllers/class_controller.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_corporate.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_minimalist.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_glassmorphism.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_neumorphism.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_material3.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_cupertino.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_cyberpunk.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_brutalist.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_academic.dart';
import 'package:smart_campus/features/teacher/screens/create_class/variants/create_class_fluent.dart';

class CreateClassScreen extends StatelessWidget {
  const CreateClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClassController());
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'INITIALIZE_CLASS',
        body: _buildVariant(style, controller),
      );
    });
  }

  Widget _buildVariant(UIStyle style, ClassController controller) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return CreateClassCorporate(controller: controller);
      case UIStyle.softMinimalist:
        return CreateClassMinimalist(controller: controller);
      case UIStyle.glassmorphism:
        return CreateClassGlassmorphism(controller: controller);
      case UIStyle.neumorphism:
        return CreateClassNeumorphism(controller: controller);
      case UIStyle.material3:
        return CreateClassMaterial3(controller: controller);
      case UIStyle.cupertinoPro:
        return CreateClassCupertino(controller: controller);
      case UIStyle.cyberpunkNeon:
        return CreateClassCyberpunk(controller: controller);
      case UIStyle.brutalistBold:
        return CreateClassBrutalist(controller: controller);
      case UIStyle.academicClassic:
        return CreateClassAcademic(controller: controller);
      case UIStyle.fluentLayered:
        return CreateClassFluent(controller: controller);
    }
  }
}
