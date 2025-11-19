import '../../services/feedback_service.dart';
import '../../services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'app/bindings/app_bindings.dart';
import 'common/utils/constants/colors.dart';
import 'common/utils/local_storage/storage_utility.dart';
import 'myapp.dart';
import 'services/database_helper.dart';
import 'services/google_sign_in_service.dart';
import 'services/language_service.dart';
import 'services/local_storage_service.dart';

// The main entry point of the app.
//
// Initializes the app's bindings, services, and global state.
// Checks if the user is already logged in and tries to log in
// automatically if credentials are saved.
// Starts the app normally even if auto-login fails.
//
// Main entry point of the application.
//
// Performs the following startup tasks:
// - Initializes Flutter bindings
// - Configures Supabase authentication
// - Initializes storage and global app services
// - Attempts automatic user login if credentials are saved
// - Launches the main application widget
//
// Handles auto-login gracefully, continuing app startup even if login fails.
Future<void> main() async {
  try {
    // Initialize database factory for SQLite
    if (DatabaseHelper.isSupported) {
      DatabaseHelper.initializeDatabaseFactory();
      print('Database factory initialized successfully');
    } else {
      print('SQLite not supported on this platform');
    }
    //print('Starting app initialization...');
    // Intializing the binding for the app.
    WidgetsFlutterBinding.ensureInitialized();
    //print('Flutter bindings initialized.');

    await GetStorage.init();
    //print('GetStorage initialized.');

    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");

    // Initialize Supabase with credentials from environment variables.
    //print('Initializing Supabase...');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    //print('Supabase initialized.');

    // Initialize services
    await _initializeServices();
    // Initialize global bindings
    //print('calling the file to initialize global bindings...');

    //print('Global bindings initialized.');

    // Load saved theme preference
    //print('Loading saved theme preference...');
    final storageUtil = TStorageUtility();
    final savedThemeMode = storageUtil.getThemeMode();
    Get.changeThemeMode(savedThemeMode);
    //print('Theme set to: ${savedThemeMode.toString()}');

    // Running the App

    //print('Launching MyApp...');
    runApp(MyApp());
  } catch (e) {
    //print('ERROR DURING APP INITIALIZATION: $e');
    //print('Stack trace: $stackTrace');
    // Still try to run the app with minimal functionality
    runApp(FallbackErrorApp(error: e.toString()));
  }
}

Future<void> _initializeServices() async {
  try {
    //print('Initializing services...');
    await Get.putAsync(() => StorageService().init());
    //print('StorageService initialized.');
    await Get.putAsync(() => FeedbackService().init());
    //print('FeedbackService initialized.');
    await Get.putAsync(() => LanguageService().init());
    //print('LanguageService initialized.');
    await Get.putAsync(() => GoogleSignInService().init());
    await Get.putAsync(() => LocalStorageService().init(), permanent: true);

    // Initialize app bindings
    AppBindings.initGlobalBindings();
    print('App bindings initialized');
  } catch (e) {
    print('Error initializing services: $e');
    rethrow;
  }
}

// Simple error display app
class FallbackErrorApp extends StatelessWidget {
  final String error;

  const FallbackErrorApp({super.key, required this.error});

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
                const Icon(Icons.error_outline, color: TColors.red, size: 60),
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
