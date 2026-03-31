import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DatabaseHelper {
  static bool _initialized = false;

  static Future<void> initializeDatabaseFactory() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        // Web platform - SQLite not supported
        throw UnsupportedError('SQLite is not supported on web platform');
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop platforms
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } else {
        // Mobile platforms (Android, iOS) - use default sqflite
        // No additional initialization needed
      }

      _initialized = true;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error initializing database factory: $e');
      rethrow;
    }
  }

  static bool get isInitialized => _initialized;

  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS;
  }
}
