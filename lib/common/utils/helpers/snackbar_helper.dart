import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

enum MessageType { success, error, warning, info }

/// Enum defining different message sources
enum MessageSource {
  server, // Messages from the server/backend
  client, // Messages from client-side validation
  app, // Messages from the app itself
}

/// A utility class for showing consistent, styled snackbars throughout the app
class TSnackBar {
  TSnackBar._()
  {
    //printnt('TSnackBar initialized');
  } // Private constructor to prevent instantiation

  /// Enum defining different message types

  /// Show a snackbar with customized styling based on type and source
  static void show({
    required String title,
    required String message,
    MessageType type = MessageType.info,
    MessageSource source = MessageSource.app,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Determine icon and colors based on message type
    IconData icon;
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (type) {
      case MessageType.success:
        icon = Iconsax.tick_circle;
        backgroundColor = Colors.green;
        break;
      case MessageType.error:
        icon = Iconsax.warning_2;
        backgroundColor = Colors.red;
        break;
      case MessageType.warning:
        icon = Iconsax.info_circle;
        backgroundColor = Colors.orange;
        break;
      case MessageType.info:
        icon = Iconsax.information;
        backgroundColor = TColors.deepPurple;
        break;
    }

    // Add source prefix to title if not app source
    String sourcePrefix = '';
    switch (source) {
      case MessageSource.server:
        sourcePrefix = '[Server] ';
        break;
      case MessageSource.client:
        sourcePrefix = '[Client] ';
        break;
      case MessageSource.app:
        // No prefix for app messages
        break;
    }

    // Show the snackbar
    Get.snackbar(
      sourcePrefix + title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      icon: Icon(icon, color: textColor),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCirc,
      reverseAnimationCurve: Curves.easeInCirc,
      overlayBlur: 0,
      overlayColor: Colors.black.withAlpha(20),
    );
  }

  /// Convenience method for showing success messages
  static void showSuccess({
    required String message,
    String title = 'Success',
    MessageSource source = MessageSource.app,
  }) {
    show(
      title: title,
      message: message,
      type: MessageType.success,
      source: source,
    );
  }

  /// Convenience method for showing error messages
  static void showError({
    required String message,
    String title = 'Error',
    MessageSource source =
        MessageSource.app, // No need for TSnackBar.MessageSource
  }) {
    show(
      title: title,
      message: message,
      type: MessageType.error,
      source: source,
    );
  }

  /// Convenience method for showing warning messages
  static void showWarning({
    required String message,
    String title = 'Warning',
    MessageSource source = MessageSource.app,
  }) {
    show(
      title: title,
      message: message,
      type: MessageType.warning,
      source: source,
    );
  }

  /// Convenience method for showing info messages
  static void showInfo({
    required String message,
    String title = 'Information',
    MessageSource source = MessageSource.app,
  }) {
    show(
      title: title,
      message: message,
      type: MessageType.info,
      source: source,
    );
  }

  /// Show a server error message
  static void showServerError({
    required String message,
    String title = 'Server Error',
  }) {
    showError(title: title, message: message, source: MessageSource.server);
  }

  /// Show a validation error message
  static void showValidationError({
    required String message,
    String title = 'Validation Error',
  }) {
    showError(title: title, message: message, source: MessageSource.client);
  }

  /// Show a network error message
  static void showNetworkError({
    String message = 'Please check your internet connection and try again.',
    String title = 'Network Error',
  }) {
    showError(title: title, message: message, source: MessageSource.server);
  }

  /// Show an authentication error message
  static void showAuthError({
    required String message,
    String title = 'Authentication Error',
  }) {
    showError(title: title, message: message, source: MessageSource.server);
  }
}
