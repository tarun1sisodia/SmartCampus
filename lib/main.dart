import 'package:attedance__/app/bindings/app_bindings.dart';
import 'package:attedance__/myapp.dart';
import 'package:attedance__/services/feedvack_service.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'services/language_service.dart';

/// The main entry point of the app.
///
/// Initializes the app's bindings, services, and global state.
/// Checks if the user is already logged in and tries to log in
/// automatically if credentials are saved.
/// Starts the app normally even if auto-login fails.
///
/// Main entry point of the application.
///
/// Performs the following startup tasks:
/// - Initializes Flutter bindings
/// - Configures Supabase authentication
/// - Initializes storage and global app services
/// - Attempts automatic user login if credentials are saved
/// - Launches the main application widget
///
/// Handles auto-login gracefully, continuing app startup even if login fails.
Future<void> main() async {
  //Intializing the binding for the app .
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Supabase by directly providing the url and key . they are very secret and import for app to run with backend properly .
  await Supabase.initialize(
    url: 'https://lbcmezrvrmbsaqoqxjnm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxiY21lenJ2cm1ic2Fxb3F4am5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5ODM1MzQsImV4cCI6MjA1ODU1OTUzNH0.-7_C8OG_ws5qNaCZd6UBIPGl_RYeWsz_EGjixi09zQU',
  );
  /* await Supabase.initialize(
    url: 'https://bwlbpkasioafzfbtzytj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3bGJwa2FzaW9hZnpmYnR6eXRqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyMTMzMjQsImV4cCI6MjA1OTc4OTMyNH0.wuknuC3aGiDXP4Yn4SJp6iBP3rgzolr4knrpsT5ha9E',
  );*/

  // Initialize services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => FeedbackService().init());
  await Get.putAsync(() => LanguageService().init());

  // Initialize global bindings
  AppBindings.initGlobalBindings();
  // await attemptAutoLogin();
  // Running the App
  final storageService = Get.find<StorageService>();

  // Check if user credentials are saved
  final bool isLoggedIn =
      storageService.getRememberUserStatus() &&
      storageService.getUserEmail() != null &&
      storageService.getUserPassword() != null;

  if (isLoggedIn) {
    try {
      final email = storageService.getUserEmail()!;
      final password = storageService.getUserPassword()!;

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      //print('Auto-login successful');
    } catch (e) {
      //print('Auto-login failed: $e');
      Get.snackbar(
        'Auto-login Failed',
        'Unable to log in automatically. Please log in manually.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  runApp(MyApp());
}
// Future<void> attemptAutoLogin() async {
  
// }


