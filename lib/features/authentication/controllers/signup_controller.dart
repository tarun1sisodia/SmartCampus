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
        return;
      }
      
      if (phoneController.text.trim().isEmpty) {
        errorMessage.value = 'Phone number is required';
        return;
      }
      
      // Sign up the user with Supabase Auth
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
        },
      );
      
      if (response.user == null) {
        errorMessage.value = 'Registration failed';
        return;
      }
      
      // Success - will navigate to verification screen from the UI
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow; // Rethrow to handle in the UI
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
