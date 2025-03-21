import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final supabase = Supabase.instance.client;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> resetPassword() async {
    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = 'Invalid email address';
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Request password reset email from Supabase
      await supabase.auth.resetPasswordForEmail(emailController.text.trim());

      // Success - no need to set a message as we'll navigate to confirmation screen
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow; // Rethrow to handle in the UI
    } finally {
      isLoading.value = false;
    }
  }
}
