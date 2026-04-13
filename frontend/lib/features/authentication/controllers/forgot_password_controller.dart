import 'package:smart_campus/common/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../../core/api/api_client.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  // Removed Supabase client dependency

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> resetPassword() async {
    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = TTexts.invalidEmail;
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Request password reset email from Backend
      await ApiClient.dio.post('/auth/forgot-password', data: {
        'email': emailController.text.trim(),
      });

      // Success - no need to set a message as we'll navigate to confirmation screen
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      errorMessage.value = e.toString();
      rethrow; // Rethrow to handle in the UI
    } finally {
      isLoading.value = false;
    }
  }
}
