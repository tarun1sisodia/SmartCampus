import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthController extends GetxController {
  static SupabaseAuthController get instance => Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Store these temporarily during the signup process
  // These will be used after email verification to store user data in the database
  String _tempName = '';
  String _tempPhone = '';

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final supabase = Supabase.instance.client;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  final rememberMe = false.obs;

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

  Future<void> signInWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
        // Save credentials if remember me is checked
        if (rememberMe.value) {
          StorageService.instance.saveUserCredentials(
            emailController.text.trim(),
            passwordController.text,
          );
        }
      
        // Check if user exists in the users table, if not create a new entry
        try {
          final userData = await supabase
              .from('users')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();
        
          if (userData == null) {
            // User doesn't exist in the database yet, create a new entry
            await supabase.from('users').insert({
              'id': response.user!.id,
              'name': response.user!.userMetadata?['name'] ?? 'New User',
              'email': response.user!.email ?? '',
              'phone': response.user!.userMetadata?['phone'] ?? '',
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          print('Error checking/creating user data: $e');
          // Continue with navigation even if there's an error here
        }
      
        // Navigate to home using named route
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = 'Authentication failed';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      TSnackBar.showAuthError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> signUpWithEmail(String name, String phone) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Store these temporarily for later use after email verification
      _tempName = name;
      _tempPhone = phone;

      // Sign up the user with Supabase Auth
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user == null) {
        errorMessage.value = 'Registration failed';
      }
      // We don't store user data yet - we'll do that after email verification
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow; // Rethrow to handle in the UI
    } finally {
      isLoading.value = false;
    }
  }

  // This method will be called after email verification is confirmed
  Future<void> storeUserData() async {
    try {
      isLoading.value = true;

      // Get the current user
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Log the user data being stored
        print(
          'Storing user data: id=${user.id}, name=$_tempName, email=${user.email}, phone=$_tempPhone',
        );

        // Store user data in the Supabase table
        await supabase.from('users').insert({
          'id': user.id,
          'name': _tempName,
          'email': user.email,
          'phone': _tempPhone,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Clear temporary data
        _tempName = '';
        _tempPhone = '';
      }
    } catch (e) {
      print('Error storing user data: $e');
      errorMessage.value = 'Failed to store user data';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      isLoading.value = true;
      await supabase.auth.resend(type: OtpType.signup, email: email);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user's email is verified
  Future<bool> checkEmailVerified() async {
    try {
      final response = await supabase.auth.getUser();
      return response.user?.emailConfirmedAt != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> resetPassword() async {
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
