import 'package:attedance__/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedCredentials();
  }

  void loadSavedCredentials() {
    final remember = StorageService.instance.getRememberUserStatus();
    if (remember) {
      final email = StorageService.instance.getUserEmail();
      final password = StorageService.instance.getUserPassword();

      if (email != null && password != null) {
        emailController.text = email;
        passwordController.text = password;
        rememberMe.value = true;
      }
    }
  }

  void setRememberMe(bool value) {
    rememberMe.value = value;
    StorageService.instance.setRememberUserStatus(value);

    if (value) {
      // Save current credentials
      StorageService.instance.saveUserCredentials(
        emailController.text,
        passwordController.text,
      );
    } else {
      // Clear saved credentials
      StorageService.instance.clearUserCredentials();
    }
  }

  void login() async {
    try {
      // Your login logic here
      if (rememberMe.value) {
        StorageService.instance.saveUserCredentials(
          emailController.text,
          passwordController.text,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
