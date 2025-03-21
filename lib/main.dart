import 'package:attedance__/bindings/app_bindings.dart';
import 'package:attedance__/routes/app_routes.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/theme/custom_themes/text_field_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://hgjwopqcwptinpcihquk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhnandvcHFjd3B0aW5wY2locXVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1ODQyOTksImV4cCI6MjA1ODE2MDI5OX0.QftWVNrZOrwlyRV1lwq_jW1_fmRab9KhjB7j08Zxdfk',
  );


  // Initialize services
  await Get.putAsync(() => StorageService().init());

  // Initialize global bindings
  AppBindings.initGlobalBindings();

  // Check if user is already logged in
  final storageService = Get.find<StorageService>();
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

    // Determine initial route
    String initialRoute;
    Bindings initialBinding;

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        inputDecorationTheme: TTextFieldTheme.lightInputDecoration,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        inputDecorationTheme: TTextFieldTheme.darkInputDecoration,
      ),
      themeMode: ThemeMode.system, // Respects system theme setting
      debugShowCheckedModeBanner: false,

      // Set initial route based on authentication status
      initialRoute: initialRoute,
      initialBinding: initialBinding,

      // Use the routes defined in AppRoutes
      getPages: AppRoutes.routes,
    );
  }
}
