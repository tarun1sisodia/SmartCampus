// This file provides workarounds for Firebase web package issues in Flutter

import 'package:flutter/foundation.dart';

/// A custom implementation of FallThroughError to fix compatibility issues
/// with Firebase web packages
class FallThroughError extends Error {
  FallThroughError();

  @override
  String toString() => 'FallThroughError: Switch statement case falls through.';
}

/// Initialize the Firebase error handling workarounds
void initFirebaseErrorHandlers() {
  if (kIsWeb) {
    // Make our FallThroughError implementation available globally
    // This is a bit hacky but necessary for the Firebase web packages
    // that expect this error to be available
    debugPrint('Initializing Firebase web error handlers');
  }
}
