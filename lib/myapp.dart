import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/app/theme/custom_themes/text_field_theme.dart';
import 'package:attedance__/common/translations/app_translations.dart';
import 'package:attedance__/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    // _autoLogin();
    return GetMaterialApp(
      title: 'Attendance App',
      translations: AppTranslations(),
      locale: languageService.currentLocale.value,
      fallbackLocale: const Locale('en', 'US'),
      // Theme Data is for the UI in Light theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        inputDecorationTheme: TTextFieldTheme.lightInputDecoration,
      ),
      // Dark theme design for UI in Dark Theme
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        inputDecorationTheme: TTextFieldTheme.darkInputDecoration,
      ),
      themeMode: ThemeMode.system, // Respects system theme setting
      debugShowCheckedModeBanner: false, // Remove debug banner from UI
      // Set the splash screen as the initial route
      initialRoute: AppRoutes.splash,
      // Managing the routes by disposing of unused controllers from memory
      smartManagement: SmartManagement.keepFactory,
      // Use the routes defined in AppRoutes
      getPages: AppRoutes.routes,
    );
  }
}
/*Future<void> _autoLogin() async {
  //print('Attempting auto-login...');

  // Initialize the storage service
  await Get.putAsync(() => StorageService().init());
  //print('StorageService initialized.');

  // Retrieve the storage service instance
final storageService = Get.find<StorageService>();
  //print('StorageService instance retrieved.');

  // Check if user credentials are saved
  final bool isLoggedIn =
      storageService.getRememberUserStatus() &&
      storageService.getUserEmail() != null &&
      storageService.getUserPassword() != null;

  //print('Is user logged in? $isLoggedIn');

  if (isLoggedIn) {
    try {
      final email = storageService.getUserEmail()!;
      final password = storageService.getUserPassword()!;
      //print('Attempting auto-login with email: $email');

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      //print('Auto-login successful.');
    } catch (e) {
      //print('Auto-login failed: $e');
      Get.snackbar(
        'Auto-login Failed',
        'Unable to log in automatically. Please log in manually.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}*/
