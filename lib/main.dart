import 'services/feedback_service.dart';
import 'services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'app/bindings/app_bindings.dart';
import 'common/utils/constants/colors.dart';
import 'common/utils/constants/api_constants.dart';
import 'common/utils/local_storage/storage_utility.dart';
import 'myapp.dart';
import 'services/database_helper.dart';
import 'services/google_sign_in_service.dart';
import 'services/language_service.dart';
import 'services/local_storage_service.dart';
import 'services/connectivity_service.dart';

// The main entry point of the app.
//
// Initializes the app's bindings, services, and global state.
//
// Performs the following startup tasks:
// - Initializes Flutter bindings
// - Configures Supabase authentication
// - Initializes storage and global app services
// - Launches the main application widget
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: '.env');

    // Enable Edge-to-Edge mode for modern Android UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Set status and navigation bars to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize database factory for SQLite
    if (DatabaseHelper.isSupported) {
      await DatabaseHelper.initializeDatabaseFactory();
    } else {
      debugPrint('SQLite not supported on this platform');
    }
    //print('Starting app initialization...');
    await GetStorage.init();
    //print('GetStorage initialized.');

    // Initialize Supabase
    //print('Initializing Supabase...');
    await Supabase.initialize(
      url: ApiConstants.url,
      anonKey: ApiConstants.anonKey,
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
    await _runAppWithMonitoring();
  } catch (e, stackTrace) {
    await Sentry.captureException(e, stackTrace: stackTrace);
    //print('ERROR DURING APP INITIALIZATION: $e');
    //print('Stack trace: $stackTrace');
    // Still try to run the app with minimal functionality
    runApp(FallbackErrorApp(error: e.toString()));
  }
}

Future<void> _runAppWithMonitoring() async {
  final dsn = ApiConstants.sentryDsn;
  if (dsn == null) {
    runApp(MyApp());
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
}

Future<void> _initializeServices() async {
  try {
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => FeedbackService().init());
    await Get.putAsync(() => LanguageService().init());
    try {
      await Get.putAsync(() => GoogleSignInService().init());
    } catch (e) {
      debugPrint('GoogleSignInService not supported on this platform: $e');
    }
    await Get.putAsync(() => LocalStorageService().init(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);

    // Initialize app bindings
    AppBindings.initGlobalBindings();
  } catch (e, stackTrace) {
    await Sentry.captureException(e, stackTrace: stackTrace);
    debugPrint('Error initializing services: $e');
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
                const Text('Please contact via github.com/tarunsisodia.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
