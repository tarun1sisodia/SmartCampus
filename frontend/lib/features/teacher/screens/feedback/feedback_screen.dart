import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../controllers/feedback_controller.dart';
import 'variants/feedback_corporate.dart';
import 'variants/feedback_minimalist.dart';
import 'variants/feedback_glassmorphism.dart';
import 'variants/feedback_neumorphism.dart';
import 'variants/feedback_material3.dart';
import 'variants/feedback_cupertino.dart';
import 'variants/feedback_cyberpunk.dart';
import 'variants/feedback_brutalist.dart';
import 'variants/feedback_academic.dart';
import 'variants/feedback_fluent.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'SEND_FEEDBACK',
        body: _buildVariant(style, controller),
      );
    });
  }

  Widget _buildVariant(UIStyle style, FeedbackController controller) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return FeedbackCorporate(controller: controller);
      case UIStyle.softMinimalist:
        return FeedbackMinimalist(controller: controller);
      case UIStyle.glassmorphism:
        return FeedbackGlassmorphism(controller: controller);
      case UIStyle.neumorphism:
        return FeedbackNeumorphism(controller: controller);
      case UIStyle.material3:
        return FeedbackMaterial3(controller: controller);
      case UIStyle.cupertinoPro:
        return FeedbackCupertino(controller: controller);
      case UIStyle.cyberpunkNeon:
        return FeedbackCyberpunk(controller: controller);
      case UIStyle.brutalistBold:
        return FeedbackBrutalist(controller: controller);
      case UIStyle.academicClassic:
        return FeedbackAcademic(controller: controller);
      case UIStyle.fluentLayered:
        return FeedbackFluent(controller: controller);
    }
  }
}
