import 'package:attedance__/bindings/app_bindings.dart';
import 'package:attedance__/navigation_menu.dart';
import 'package:attedance__/routes/app_routes.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/theme/custom_themes/text_field_theme.dart';

Future<void> main() async {
  //Intializing the binding for the app .
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase by directly providing the url and key . they are very secret and import for app to run with backend properly .
  await Supabase.initialize(
    url: 'https://hgjwopqcwptinpcihquk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhnandvcHFjd3B0aW5wY2locXVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1ODQyOTksImV4cCI6MjA1ODE2MDI5OX0.QftWVNrZOrwlyRV1lwq_jW1_fmRab9KhjB7j08Zxdfk',
  );

  // Initialize services
  await Get.putAsync(() => StorageService().init());

  // Initialize global bindings
  AppBindings.initGlobalBindings();

  // Check if user is already logged in
  final storageService = Get.find<StorageService>();
  // Checking by getting the local system data if available.
  final bool isLoggedIn =
      storageService.getRememberUserStatus() &&
      storageService.getUserEmail() != null &&
      storageService.getUserPassword() != null;

  // If credentials are saved, try to log in automatically
  if (isLoggedIn) {
    try {
      final email = storageService.getUserEmail()!;
      final password = storageService.getUserPassword()!;

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Auto-login successful');
    } catch (e) {
      print('Auto-login failed: $e');
      Get.snackbar(
        'Auto-login Failed',
        'Unable to log in automatically. Please log in manually.',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Continue with normal app startup even if auto-login fails
    }
  }
  // Running the App 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
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

      home: NavigationMenu(),
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
