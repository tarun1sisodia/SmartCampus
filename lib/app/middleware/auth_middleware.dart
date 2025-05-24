import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../features/authentication/controllers/supabase_auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      // Skip middleware for Linux platform
      bool isLinux = false;
      try {
        isLinux = Platform.isLinux;
      } catch (e) {
        print("Error checking platform: $e");
      }

      if (isLinux) {
        print("Linux platform detected, bypassing auth middleware");
        return null; // Allow access on Linux without checks
      }

      final authController = Get.isRegistered<SupabaseAuthController>()
          ? Get.find<SupabaseAuthController>()
          : null;

      // If controller is not found, redirect to login
      if (authController == null) {
        print("Auth controller not found, redirecting to login");
        return RouteSettings(name: AppRoutes.login);
      }

      // Check if the user is authenticated (synchronous check)
      final currentUser = authController.supabase.auth.currentUser;
      if (currentUser == null) {
        print("No current user, redirecting to login");
        return RouteSettings(name: AppRoutes.login);
      }

      // User is authenticated, allow access
      print("User authenticated, allowing access to route: $route");
      return null;
    } catch (e) {
      print("Error in auth middleware: $e");
      // In case of any error, redirect to login
      return RouteSettings(name: AppRoutes.login);
    }
  }
}
