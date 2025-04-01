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
  void onInit() {
    super.onInit();
    loadSavedCredentials();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  final rememberMe = false.obs;

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
      // Show a confirmation message
      TSnackBar.showInfo(
        message: 'Your credentials will be remembered for next login',
        title: 'Remember Me',
      );
    } else {
      // Clear saved credentials
      StorageService.instance.clearUserCredentials();
      // Show a confirmation message
      TSnackBar.showInfo(
        message: 'Your credentials will not be saved',
        title: 'Remember Me',
      );
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
          final userData =
              await supabase
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

        // Show success message
        TSnackBar.showSuccess(
          message: 'You have successfully logged in',
          title: 'Welcome Back',
        );

        // Navigate to home using named route
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = 'Authentication failed';
        TSnackBar.showAuthError(
          message: 'Authentication failed. Please try again.',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();

      // Enhanced error handling with specific messages
      if (e is AuthException) {
        if (e.message.contains('Invalid login credentials')) {
          TSnackBar.showAuthError(
            message: 'Invalid email or password. Please try again.',
          );
        } else if (e.message.contains('Email not confirmed')) {
          TSnackBar.showAuthError(
            message: 'Please verify your email before logging in.',
          );
        } else {
          TSnackBar.showAuthError(message: e.message);
        }
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        TSnackBar.showNetworkError();
      } else {
        TSnackBar.showServerError(message: e.toString());
      }
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
        TSnackBar.showAuthError(
          message: 'Registration failed. Please try again.',
        );
      } else {
        // Show success message
        TSnackBar.showSuccess(
          message:
              'Registration successful! Please check your email to verify your account.',
          title: 'Account Created',
        );
      }
      // We don't store user data yet - we'll do that after email verification
    } catch (e) {
      errorMessage.value = e.toString();

      // Enhanced error handling with specific messages
      if (e is AuthException) {
        if (e.message.contains('already registered')) {
          TSnackBar.showAuthError(
            message:
                'This email is already registered. Please use a different email or try logging in.',
          );
        } else {
          TSnackBar.showAuthError(message: e.message);
        }
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        TSnackBar.showNetworkError();
      } else {
        TSnackBar.showServerError(message: e.toString());
      }

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

        // Show success message
        TSnackBar.showSuccess(
          message: 'Your account has been fully set up!',
          title: 'Setup Complete',
        );
      }
    } catch (e) {
      print('Error storing user data: $e');
      errorMessage.value = 'Failed to store user data';

      if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        TSnackBar.showNetworkError();
      } else if (e.toString().contains('duplicate') ||
          e.toString().contains('unique constraint')) {
        TSnackBar.showAuthError(
          message: 'This user data already exists in our system.',
        );
      } else {
        TSnackBar.showServerError(
          message: 'Failed to store your information. Please try again later.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      isLoading.value = true;
      await supabase.auth.resend(type: OtpType.signup, email: email);

      // Show success message
      TSnackBar.showSuccess(
        message: 'Verification email has been resent to $email',
        title: 'Email Sent',
      );
    } catch (e) {
      errorMessage.value = e.toString();

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        TSnackBar.showNetworkError();
      } else if (e.toString().contains('too many requests') ||
          e.toString().contains('rate limit')) {
        TSnackBar.showAuthError(
          message:
              'Too many attempts. Please wait a moment before trying again.',
        );
      } else {
        TSnackBar.showServerError(
          message: 'Failed to resend verification email: ${e.toString()}',
        );
      }

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
      TSnackBar.showServerError(
        message: 'Failed to check email verification status: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> resetPassword() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Request password reset email from Supabase
      await supabase.auth.resetPasswordForEmail(emailController.text.trim());

      // Show success message
      TSnackBar.showSuccess(
        message: 'Password reset instructions have been sent to your email',
        title: 'Reset Email Sent',
      );
    } catch (e) {
      errorMessage.value = e.toString();

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        TSnackBar.showNetworkError();
      } else if (e.toString().contains('not found') ||
          e.toString().contains('no user')) {
        TSnackBar.showAuthError(
          message: 'No account found with this email address.',
        );
      } else {
        TSnackBar.showServerError(
          message: 'Failed to send password reset email: ${e.toString()}',
        );
      }

      rethrow; // Rethrow to handle in the UI
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;

      await supabase.auth.signOut();

      // Clear saved credentials if not using remember me
      if (!rememberMe.value) {
        StorageService.instance.clearUserCredentials();
      }

      // Show success message
      TSnackBar.showSuccess(
        message: 'You have been successfully logged out',
        title: 'Signed Out',
      );

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      TSnackBar.showServerError(message: 'Failed to sign out: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
