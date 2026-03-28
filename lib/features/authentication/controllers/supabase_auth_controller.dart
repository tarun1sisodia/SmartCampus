import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/bindings/app_bindings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../navigation_menu.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class SupabaseAuthController extends GetxController {
  static SupabaseAuthController get instance => Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String _tempName = '';
  String _tempPhone = '';

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    //printrint('SupabaseAuthController initialized');
    loadSavedCredentials();
  }

  @override
  void onClose() {
    //printrint('SupabaseAuthController disposed');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  final rememberMe = false.obs;

  void loadSavedCredentials() {
    //printrint('Loading saved credentials');
    final remember = StorageService.instance.getRememberUserStatus();
    if (remember) {
      final email = StorageService.instance.getUserEmail();
      final password = StorageService.instance.getUserPassword();

      if (email != null && password != null) {
        emailController.text = email;
        passwordController.text = password;
        rememberMe.value = true;
        //printrint('Loaded saved credentials: email=$email');
      }
    }
  }

  void setRememberMe(bool value) {
    //printrint('Setting remember me: $value');
    rememberMe.value = value;
    StorageService.instance.setRememberUserStatus(value);

    if (value) {
      StorageService.instance.saveUserCredentials(
        emailController.text,
        passwordController.text,
      );
      //printrint('Credentials saved');
      TSnackBar.showInfo(
        message: 'Your credentials will be remembered for next login',
        title: 'Remember Me',
      );
    } else {
      StorageService.instance.clearUserCredentials();
      //printrint('Credentials cleared');
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

       // print('Attempting to sign in with email: ${emailController.text.trim()}');

      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
         // print('Sign-in successful: user=${response.user!.id}');
        if (rememberMe.value) {
          StorageService.instance.saveUserCredentials(
            emailController.text.trim(),
            passwordController.text,
          );
        }

        try {
          final userData = await supabase
              .from('users')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

           // print('User data retrieved: $userData');

          if (userData == null) {
             // print('User not found in database, creating new entry');
            await supabase.from('users').insert({
              'id': response.user!.id,
              'name': response.user!.userMetadata?['name'] ?? 'New User',
              'email': response.user!.email ?? '',
              'phone': response.user!.userMetadata?['phone'] ?? '',
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
           // print('Error checking/creating user data: $e');
        }

        TSnackBar.showSuccess(
          message: 'You have successfully logged in',
          title: 'Welcome Back',
        );

        // Check if we're on Linux
        bool isLinux = false;
        try {
          isLinux = Platform.isLinux;
           // print('Platform is Linux: $isLinux');
        } catch (e) {
           // print('Error checking platform: $e');
        }

        // Force navigation to home route
         // print('Navigating to home route: ${AppRoutes.home}');

        // Use Get.offAll to bypass middleware
        Get.offAll(
          () => NavigationMenu(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
        );
      } else {
        errorMessage.value = 'Authentication failed';
         // print('Authentication failed');
        TSnackBar.showAuthError(
          message: 'Authentication failed. Please try again.',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
       // print('Error during sign-in: $e');
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
    //printrint('Signing up with email: name=$name, phone=$phone');
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _tempName = name;
      _tempPhone = phone;

      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user == null) {
        errorMessage.value = 'Registration failed';
        //printrint('Registration failed');
        TSnackBar.showAuthError(
          message: 'Registration failed. Please try again.',
        );
      } else {
        //printrint('Registration successful: user=${response.user}');
        TSnackBar.showSuccess(
          message:
              'Registration successful! Please check your email to verify your account.',
          title: 'Account Created',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      //printrint('Error during sign-up: $e');
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

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> storeUserData() async {
    //printrint('Storing user data');
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;

      if (user != null) {
        //printrint('Storing user data: id=${user.id}, name=$_tempName, email=${user.email}, phone=$_tempPhone');
        await supabase.from('users').insert({
          'id': user.id,
          'name': _tempName,
          'email': user.email,
          'phone': _tempPhone,
          'created_at': DateTime.now().toIso8601String(),
        });

        _tempName = '';
        _tempPhone = '';

        TSnackBar.showSuccess(
          message: 'Your account has been fully set up!',
          title: 'Setup Complete',
        );
      }
    } catch (e) {
      //printrint('Error storing user data: $e');
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
    //printrint('Resending verification email to $email');
    try {
      isLoading.value = true;
      await supabase.auth.resend(type: OtpType.signup, email: email);

      TSnackBar.showSuccess(
        message: 'Verification email has been resent to $email',
        title: 'Email Sent',
      );
    } catch (e) {
      errorMessage.value = e.toString();
      //printrint('Error resending verification email: $e');
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

  Future<bool> checkEmailVerified() async {
    //printrint('Checking if email is verified');
    try {
      final response = await supabase.auth.getUser();
      final isVerified = response.user?.emailConfirmedAt != null;
      //printrint('Email verification status: $isVerified');
      return isVerified;
    } catch (e) {
      //printrint('Error checking email verification: $e');
      TSnackBar.showServerError(
        message: 'Failed to check email verification status: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> resetPassword() async {
    //printrint('Resetting password for email: ${emailController.text.trim()}');
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await supabase.auth.resetPasswordForEmail(emailController.text.trim());

      TSnackBar.showSuccess(
        message: 'Password reset instructions have been sent to your email',
        title: 'Reset Email Sent',
      );
    } catch (e) {
      errorMessage.value = e.toString();
      //printrint('Error resetting password: $e');
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

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

// method to check if the current session is valid
  Future<bool> isSessionValid() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // Check if token is expired
      final session = supabase.auth.currentSession;
      if (session == null) {
        return false;
      }

      // If the token is about to expire in the next hour, refresh it
      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      final now = DateTime.now();
      if (expiresAt.difference(now).inHours < 1) {
        // Try to refresh the session
        await supabase.auth.refreshSession();
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

// Modify signOut to handle biometric settings
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Get biometric service
      final biometricAuthService = Get.find<BiometricAuthService>();

      // If we're using biometrics, ask if the user wants to keep it enabled
      if (biometricAuthService.isBiometricEnabled.value) {
        final keepBiometrics = await Get.dialog<bool>(
              AlertDialog(
                title: Text('Biometric Authentication'),
                content: Text(
                    'Do you want to keep biometric authentication enabled for next login?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!keepBiometrics) {
          try {
            await biometricAuthService.disableBiometrics();
          } catch (e) {
            TSnackBar.showServerError(
              message:
                  'Failed to disable biometric authentication: ${e.toString()}',
            );
          }
        }
      }

      await supabase.auth.signOut();

      if (!rememberMe.value) {
        StorageService.instance.clearUserCredentials();
      }

      TSnackBar.showSuccess(
        message: 'You have been successfully logged out',
        title: 'Signed Out',
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      TSnackBar.showServerError(message: 'Failed to sign out: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
