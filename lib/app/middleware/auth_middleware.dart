import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../features/authentication/controllers/supabase_auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      // Bypass authentication for Linux platform
      if (Platform.isLinux) {
        return null;
      }

      final authController = Get.isRegistered<SupabaseAuthController>()
          ? Get.find<SupabaseAuthController>()
          : null;

      // If controller is not found, redirect to login
      if (authController == null) {
        return RouteSettings(name: AppRoutes.login);
      }

      // Platform-specific logic (example: block web or desktop if needed)
      if (kIsWeb) {
        // Add web-specific checks here if needed
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Add mobile-specific checks here if needed
      } else if (Platform.isWindows || Platform.isMacOS) {
        // Add desktop-specific checks here if needed
      }

      // Check if the session is valid
      if (authController.isSessionValid != true) {
        // Optionally, you can clear user data or perform other actions here
        return RouteSettings(name: AppRoutes.login);
      }

      // Allow access to the route
      return null;
    } catch (e) {
      // In case of any error, redirect to login
      return RouteSettings(name: AppRoutes.login);
    }
  }
}