import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../../../services/language_service.dart';
import '../controllers/teacher_profile_controller.dart';
import 'variants/settings/settings_corporate.dart';
import 'variants/settings/settings_minimalist.dart';
import 'variants/settings/settings_glassmorphism.dart';
import 'variants/settings/settings_neumorphism.dart';
import 'variants/settings/settings_material3.dart';
import 'variants/settings/settings_cupertino.dart';
import 'variants/settings/settings_cyberpunk.dart';
import 'variants/settings/settings_brutalist.dart';
import 'variants/settings/settings_academic.dart';
import 'variants/settings/settings_fluent.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherProfileController());
    final languageService = Get.find<LanguageService>();
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'SETTINGS_MANIFEST',
        body: _buildVariant(style, controller, languageService),
      );
    });
  }

  Widget _buildVariant(UIStyle style, TeacherProfileController controller, LanguageService languageService) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return SettingsCorporate(controller: controller, languageService: languageService);
      case UIStyle.softMinimalist:
        return SettingsMinimalist(controller: controller, languageService: languageService);
      case UIStyle.glassmorphism:
        return SettingsGlassmorphism(controller: controller, languageService: languageService);
      case UIStyle.neumorphism:
        return SettingsNeumorphism(controller: controller, languageService: languageService);
      case UIStyle.material3:
        return SettingsMaterial3(controller: controller, languageService: languageService);
      case UIStyle.cupertinoPro:
        return SettingsCupertino(controller: controller, languageService: languageService);
      case UIStyle.cyberpunkNeon:
        return SettingsCyberpunk(controller: controller, languageService: languageService);
      case UIStyle.brutalistBold:
        return SettingsBrutalist(controller: controller, languageService: languageService);
      case UIStyle.academicClassic:
        return SettingsAcademic(controller: controller, languageService: languageService);
      case UIStyle.fluentLayered:
        return SettingsFluent(controller: controller, languageService: languageService);
    }
  }
}
