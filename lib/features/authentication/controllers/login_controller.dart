import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../services/storage_service.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    //printnt('LoginController initialized');
    loadSavedCredentials();
  }

  void loadSavedCredentials() {
    //printnt('Loading saved credentials...');
    final remember = StorageService.instance.getRememberUserStatus();
    if (remember) {
      final email = StorageService.instance.getUserEmail();
      final password = StorageService.instance.getUserPassword();

      if (email != null && password != null) {
        emailController.text = email;
        passwordController.text = password;
        rememberMe.value = true;
        //printnt('Credentials loaded: email=$email');
      }
    }
  }

  void setRememberMe(bool value) {
    //printnt('Setting rememberMe to $value');
    rememberMe.value = value;
    StorageService.instance.setRememberUserStatus(value);

    if (value) {
      // Save current credentials
      StorageService.instance.saveUserCredentials(
        emailController.text,
        passwordController.text,
      );
      //printnt('Credentials saved: email=${emailController.text}');
      // Show a confirmation message
      TSnackBar.showInfo(
        message: 'Your credentials will be remembered for next login',
        title: 'Remember Me',
      );
    } else {
      // Clear saved credentials
      StorageService.instance.clearUserCredentials();
      //printnt('Credentials cleared');
      // Show a confirmation message
      TSnackBar.showInfo(
        message: 'Your credentials will not be saved',
        title: 'Remember Me',
      );
    }
  }

  bool isUserLoggedIn() {
    final email = StorageService.instance.getUserEmail();
    final password = StorageService.instance.getUserPassword();
    final loggedIn = email != null && password != null;
    //printnt('Is user logged in? $loggedIn');
    return loggedIn;
  }

  void login() async {
    //printnt('Attempting to log in...');
    try {
      // Your login logic here
      if (rememberMe.value) {
        StorageService.instance.saveUserCredentials(
          emailController.text,
          passwordController.text,
        );
        //printnt('Credentials saved during login: email=${emailController.text}');
      }

      // Show success message
      TSnackBar.showSuccess(
        message: 'You have successfully logged in',
        title: 'Welcome Back',
      );
      //printnt('Login successful');
    } catch (e) {
      //printnt('Login failed: $e');
      // Determine if it's a server error or client error
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        TSnackBar.showNetworkError();
      } else if (e.toString().contains('auth') ||
          e.toString().contains('credentials')) {
        TSnackBar.showAuthError(
          message: 'Invalid email or password. Please try again.',
        );
      } else {
        TSnackBar.showServerError(message: e.toString());
      }
    }
  }

  @override
  void onClose() {
    //printnt('Disposing LoginController');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
