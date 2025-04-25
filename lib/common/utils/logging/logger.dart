import 'package:logger/web.dart';

/// TLogger: A powerful logging utility with multiple severity levels
/// Built on top of the Logger package with optimized configuration
class TLogger {
  // Private constructor to prevent instantiation   
  TLogger._()
  {
    //printnt('TLogger initialized');
  } // Added private constructor
  // Single logger instance with pretty printing and debug level configuration
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    level: Level.debug,
  );


  /// Debug level logging for development information
  /// Usage: TLogger.debug("Fetching user data...")
  static void debug(String message) {
    _logger.d(message);
  }

  /// Info level logging for general application flow
  /// Usage: TLogger.info("User successfully logged in")
  static void info(String message) {
    _logger.i(message);
  }

  /// Warning level logging for potential issues
  /// Usage: TLogger.warning("API response delayed")
  static void warning(String message) {
    _logger.w(message);
  }

  /// Error level logging with stack trace support
  /// Usage: TLogger.erro("Payment failed", paymentError)
  static void erro(String message, [dynamic error]) {
    _logger.e(message, error: error, stackTrace: StackTrace.current);
  }
}
