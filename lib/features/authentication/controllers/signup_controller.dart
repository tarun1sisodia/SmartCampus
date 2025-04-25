import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends GetxController {
  // Text controllers for form fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final passwordVisible = false.obs;

  // Supabase client
  final supabase = Supabase.instance.client;


  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  // Sign up with email and password
  Future<void> signUpWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate inputs
      if (nameController.text.trim().isEmpty) {
        errorMessage.value = 'Name is required';
        TSnackBar.showValidationError(
          message: 'Please enter your name to continue',
        );
        return;
      }

      if (phoneController.text.trim().isEmpty) {
        errorMessage.value = 'Phone number is required';
        TSnackBar.showValidationError(
          message: 'Please enter your phone number to continue',
        );
        return;
      }

      // Log input data for debugging
      //////printnt('Signing up with:');
      //////printnt('Email: ${emailController.text.trim()}');
      //////printnt('Password: ${passwordController.text}');
      //////printnt('Name: ${nameController.text.trim()}');
      //////printnt('Phone: ${phoneController.text.trim()}');

      // Sign up the user with Supabase Auth
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
        },
      );

      // Log response for debugging
      //////printnt('Supabase response: ${response.toString()}');

      if (response.user == null) {
        errorMessage.value = 'Registration failed';
        TSnackBar.showServerError(
          message: 'Unable to create your account. Please try again.',
        );
        return;
      }

      // Success message
      TSnackBar.showSuccess(
        message: 'Account created successfully! Please verify your email.',
        title: 'Registration Complete',
      );
    } catch (e) {
      errorMessage.value = e.toString();

      // Log error for debugging
      //////printnt('Error during sign-up: $e');

      // Determine error type
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        TSnackBar.showNetworkError();
      } else if (e.toString().contains('already exists')) {
        TSnackBar.showError(
          message: 'An account with this email already exists.',
          title: 'Registration Failed',
          source: MessageSource.server,
        );
      } else {
        TSnackBar.showServerError(message: e.toString());
      }

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;
      await supabase.auth.resend(
        type: OtpType.signup,
        email: emailController.text.trim(),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
