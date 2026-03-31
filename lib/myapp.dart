import 'app/theme/theme_controller.dart';
import 'common/ui_patterns/ui_style_controller.dart';
// import 'package:smart_campus/app/theme/theme.dart';

import 'services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_routes.dart';
import 'common/translations/app_translations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    final themeController = Get.put(ThemeController());
    Get.put(UIStyleController());

    return Obx(() => GetMaterialApp(
          title: 'Smart Campus',
          translations: AppTranslations(),
          locale: languageService.currentLocale.value,
          fallbackLocale: const Locale('en', 'US'),
          theme: themeController.themeData,
          themeMode:
              themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          debugShowCheckedModeBanner: false, // Remove debug banner from UI
          // Set the splash screen as the initial route
          initialRoute: AppRoutes.splash,
          // Managing the routes by disposing of unused controllers from memory
          smartManagement: SmartManagement.keepFactory,
          // Use the routes defined in AppRoutes
          getPages: AppRoutes.routes,
        ));
  }
}
