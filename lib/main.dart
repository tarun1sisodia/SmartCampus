import 'package:SmartCampus/app/bindings/app_bindings.dart';
import 'package:SmartCampus/myapp.dart';
import 'package:SmartCampus/services/feedback_service.dart';
import 'package:SmartCampus/services/storage_service.dart';
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
  try {
    print('Starting app initialization...');

    // Intializing the binding for the app.
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter bindings initialized.');

    await GetStorage.init();
    print('GetStorage initialized.');

    // Initialize Supabase by directly providing the url and key.
    print('Initializing Supabase...');
    await Supabase.initialize(
      url: 'https://iudnkcysaeyikkbkazoh.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml1ZG5rY3lzYWV5aWtrYmthem9oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5NTMwNzQsImV4cCI6MjA2MDUyOTA3NH0.aaDLHp1TOQA24ZIFleT3yu3QpCxvY1AqfubGMb1Ju4g',
    );
    print('Supabase initialized.');

    // Initialize services
    print('Initializing services...');
    await Get.putAsync(() => StorageService().init());
    print('StorageService initialized.');
    await Get.putAsync(() => FeedbackService().init());
    print('FeedbackService initialized.');
    await Get.putAsync(() => LanguageService().init());
    print('LanguageService initialized.');

    // Initialize global bindings
    print('calling the file to initialize global bindings...');
    AppBindings.initGlobalBindings();
    print('Global bindings initialized.');

    // Running the App
    print('Launching MyApp...');
    runApp(MyApp());
  } catch (e, stackTrace) {
    print('ERROR DURING APP INITIALIZATION: $e');
    print('Stack trace: $stackTrace');
    // Still try to run the app with minimal functionality
    runApp(FallbackErrorApp(error: e.toString()));
  }
}

// Simple error display app
class FallbackErrorApp extends StatelessWidget {
  final String error;

  const FallbackErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text('App Initialization Error',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                const Text('Please contact support with this information.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
