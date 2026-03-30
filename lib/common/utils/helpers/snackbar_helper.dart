import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/text_strings.dart';

enum MessageType { success, error, warning, info }

//Enum defining different message sources
enum MessageSource {
  server, // Messages from the server/backend
  client, // Messages from client-side validation
  app, // Messages from the app itself
}

//A utility class for showing consistent, styled snackbars throughout the app
class TSnackBar {
  TSnackBar._() {
    //print('TSnackBar initialized');
  } // Private constructor to prevent instantiation

  //Enum defining different message types

  //Show a snackbar with customized styling based on type and source
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
        backgroundColor = TColors.primary;
        break;
    }

    // source prefix to title if not app source
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

    // Check if Overlay/Context is available
    final context = Get.context;
    if (context == null) {
      debugPrint(
          'Skipping snackbar: No context found. Title: $title, Message: $message');
      return;
    }

    // Use addPostFrameCallback to ensure we don't show snackbar during a build/navigator transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) return;

      // Ensure the navigator is ready
      if (Get.key.currentState == null) {
        debugPrint('Skipping snackbar: Get.key.currentState is null');
        return;
      }

      Get.showSnackbar(
        GetSnackBar(
          title: sourcePrefix + title,
          message: message,
          snackPosition: position,
          backgroundColor: backgroundColor,
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          icon: Icon(icon, color: textColor),
          duration: duration,
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutCirc,
          reverseAnimationCurve: Curves.easeInCirc,
          overlayBlur: 0,
          overlayColor: TColors.dark.withAlpha(20),
        ),
      );
    });
  }

  //Convenience method for showing success messages
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

  //Convenience method for showing error messages
  static void showError({
    required String message,
    String title = TTexts.error,
    MessageSource source = MessageSource.app,
  }) {
    show(
      title: title,
      message: message,
      type: MessageType.error,
      source: source,
    );
  }

  //Convenience method to check if there is an error message
  static bool hasError(String message, {bool handle = false}) {
    bool containsError = message.toLowerCase().contains(TTexts.error) ||
        message.toLowerCase().contains('failed') ||
        message.toLowerCase().contains('exception');
    return handle ? containsError : false;
  }

  //Convenience method for showing warning messages
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

  //Convenience method for showing info messages
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

  //Show a server error message
  static void showServerError({
    required String message,
    String title = 'Server Error',
  }) {
    showError(title: title, message: message, source: MessageSource.server);
  }

  //Show a validation error message
  static void showValidationError({
    required String message,
    String title = 'Validation Error',
  }) {
    showError(title: title, message: message, source: MessageSource.client);
  }

  //Show a network error message
  static void showNetworkError({
    String message = 'Please check your internet connection and try again.',
    String title = 'Network Error',
  }) {
    showError(title: title, message: message, source: MessageSource.server);
  }

  //Show an authentication error message
  static void showAuthError({
    required String message,
    String title = 'Authentication Error',
  }) {
    showError(title: title, message: message, source: MessageSource.server);
  }
}
