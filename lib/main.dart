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
    url: 'https://otcqeieukikymmsjwfeu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90Y3FlaWV1a2lreW1tc2p3ZmV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1MjA5MDMsImV4cCI6MjA1ODA5NjkwM30.M3D533la8914BPuHQkyHWnoxN5OM4N_-vVpMDvKDMbk',
  );
  
  // Initialize services
  await Get.putAsync(() => StorageService().init());
  
  // Initialize global bindings
  AppBindings.initGlobalBindings();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if onboarding is completed
    final storageService = Get.find<StorageService>();
    final bool onboardingCompleted = storageService.getOnboardingStatus();

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

      // Set initial route based on onboarding status
      initialRoute: onboardingCompleted ? AppRoutes.login : AppRoutes.onboarding,
      
      // Use the routes defined in AppRoutes
      getPages: AppRoutes.routes,
    );
  }
}