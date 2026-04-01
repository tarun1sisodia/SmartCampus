import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/messages_corporate.dart';
import 'variants/messages_minimalist.dart';
import 'variants/messages_glassmorphism.dart';
import 'variants/messages_neumorphism.dart';
import 'variants/messages_material3.dart';
import 'variants/messages_cupertino.dart';
import 'variants/messages_cyberpunk.dart';
import 'variants/messages_brutalist.dart';
import 'variants/messages_academic.dart';
import 'variants/messages_fluent.dart';

class TeacherMessagesScreen extends StatelessWidget {
  const TeacherMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'MESSAGES',
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return const MessagesCorporate();
      case UIStyle.softMinimalist:
        return const MessagesMinimalist();
      case UIStyle.glassmorphism:
        return const MessagesGlassmorphism();
      case UIStyle.neumorphism:
        return const MessagesNeumorphism();
      case UIStyle.material3:
        return const MessagesMaterial3();
      case UIStyle.cupertinoPro:
        return const MessagesCupertino();
      case UIStyle.cyberpunkNeon:
        return const MessagesCyberpunk();
      case UIStyle.brutalistBold:
        return const MessagesBrutalist();
      case UIStyle.academicClassic:
        return const MessagesAcademic();
      case UIStyle.fluentLayered:
        return const MessagesFluent();
    }
  }
}
