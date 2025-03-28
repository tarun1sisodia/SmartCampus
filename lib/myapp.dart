import 'package:attedance__/app/bindings/app_bindings.dart';
import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/app/theme/custom_themes/text_field_theme.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  /// Builds the main widget for the application.
  ///
  /// This method checks if the onboarding process is completed and if the user is
  /// authenticated with Supabase to determine the initial route of the application.
  /// It sets up the `GetMaterialApp` with the appropriate theme, initial route, and
  /// bindings based on the user's authentication and onboarding status. The app
  /// respects the system's theme setting and manages routes using GetX's smart
  /// management.

  Widget build(BuildContext context) {
    // Check if onboarding is completed
    final storageService = Get.find<StorageService>();
    final bool onboardingCompleted = storageService.getOnboardingStatus();

    // Check if user is currently authenticated with Supabase
    final currentUser = Supabase.instance.client.auth.currentUser;
    final bool isAuthenticated = currentUser != null;

    print('Onboarding completed: $onboardingCompleted');
    print('User authenticated: $isAuthenticated');

    // Determine initial route they are very import to run the UI and Logic.
    String initialRoute;
    Bindings initialBinding;

    // Check and decide the which UI to show and redirect
    if (isAuthenticated) {
      initialRoute = AppRoutes.home;
      initialBinding = HomeBinding();
    } else if (onboardingCompleted) {
      initialRoute = AppRoutes.login;
      initialBinding = LoginBinding();
    } else {
      initialRoute = AppRoutes.onboarding;
      initialBinding = OnboardingBinding();
    }

    print('Initial route: $initialRoute');

    return GetMaterialApp(
      title: 'Attendance App',
      // Theme Data is for the UI in Light theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        inputDecorationTheme: TTextFieldTheme.lightInputDecoration,
      ),
      //Dark theme design for ui in Dark Theme
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        inputDecorationTheme: TTextFieldTheme.darkInputDecoration,
      ),
      themeMode: ThemeMode.system, // Respects system theme setting
      // remove debug banner from ui
      debugShowCheckedModeBanner: false,

      // home: NavigationMenu(),
      // Set initial route based on authentication status
      initialRoute: initialRoute,
      initialBinding: initialBinding,
      // managing the routes by dispoing the unused controllers from memory.
      smartManagement: SmartManagement.keepFactory,

      // Use the routes defined in AppRoutes
      getPages: AppRoutes.routes,
    );
  }
}
