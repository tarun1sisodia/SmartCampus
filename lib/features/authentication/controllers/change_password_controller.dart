import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class ChangePasswordController extends GetxController {
  // Text controllers for input fields
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Loading and visibility states
  final isLoading = false.obs;
  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Password strength indicators
  final passwordStrength = 0.0.obs;
  final passwordStrengthText = ''.obs;
  final passwordStrengthColor = Colors.grey.obs;

  // Password matching indicator
  final doPasswordsMatch = true.obs;

  // Supabase client
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();

    // Add listeners to text controllers
    newPasswordController.addListener(() {
      //printnt('New password changed: ${newPasswordController.text}');
      calculatePasswordStrength(newPasswordController.text);
      if (confirmPasswordController.text.isNotEmpty) {
        checkPasswordsMatch();
      }
    });

    confirmPasswordController.addListener(() {
      //printnt('Confirm password changed: ${confirmPasswordController.text}');
      checkPasswordsMatch();
    });
  }

  @override
  void onClose() {
    // Dispose text controllers
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.toggle();
    //printnt('Current password visibility toggled: ${isCurrentPasswordVisible.value}');
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.toggle();
    //printnt('New password visibility toggled: ${isNewPasswordVisible.value}');
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
    //printnt('Confirm password visibility toggled: ${isConfirmPasswordVisible.value}');
  }

  // Calculate password strength
  void calculatePasswordStrength(String password) {
    //printnt('Calculating password strength for: $password');
    if (password.isEmpty) {
      passwordStrength.value = 0.0;
      passwordStrengthText.value = '';
      passwordStrengthColor.value = Colors.grey;
      return;
    }

    double strength = 0;

    // Length check
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // Complexity checks
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2; // Uppercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2; // Lowercase
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2; // Numbers
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength += 0.2; // Special chars
    }

    // Set strength value (cap at 1.0)
    passwordStrength.value = strength > 1.0 ? 1.0 : strength;

    // Set strength text and color
    if (strength <= 0.3) {
      passwordStrengthText.value = 'Weak';
      passwordStrengthColor.value = Colors.red;
    } else if (strength <= 0.6) {
      passwordStrengthText.value = 'Medium';
      passwordStrengthColor.value = Colors.orange;
    } else {
      passwordStrengthText.value = 'Strong';
      passwordStrengthColor.value = Colors.green;
    }

    //printnt('Password strength: ${passwordStrength.value}, Text: ${passwordStrengthText.value}');
  }

  // Check if passwords match
  void checkPasswordsMatch() {
    //printnt('Checking if passwords match');
    if (confirmPasswordController.text.isEmpty) {
      doPasswordsMatch.value = true;
      return;
    }

    doPasswordsMatch.value =
        newPasswordController.text == confirmPasswordController.text;
    //printnt('Passwords match: ${doPasswordsMatch.value}');
  }

  // Validate password fields
  bool validateFields() {
    //printnt('Validating fields');
    // Check if fields are empty
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      TSnackBar.showError(message: 'All fields are required');
      return false;
    }

    // Check if new password and confirm password match
    if (newPasswordController.text != confirmPasswordController.text) {
      TSnackBar.showError(
        message: 'New password and confirm password do not match',
      );
      return false;
    }

    // Check password length
    if (newPasswordController.text.length < 8) {
      TSnackBar.showError(
        message: 'Password must be at least 8 characters long',
      );
      return false;
    }

    // Check password strength
    if (passwordStrength.value < 0.5) {
      TSnackBar.showError(message: 'Please use a stronger password');
      return false;
    }

    return true;
  }

  // Change password
  Future<void> changePassword() async {
    //printnt('Attempting to change password');
    if (!validateFields()) return;

    try {
      isLoading.value = true;

      // Get current user
      final user = supabase.auth.currentUser;
      if (user == null) {
        TSnackBar.showError(
          message: 'You must be logged in to change your password',
        );
        return;
      }

      // First verify the current password by attempting to sign in
      try {
        final response = await supabase.auth.signInWithPassword(
          email: user.email!,
          password: currentPasswordController.text,
        );

        if (response.user == null) {
          TSnackBar.showError(message: 'Current password is incorrect');
          return;
        }
      } catch (e) {
        TSnackBar.showError(message: 'Current password is incorrect');
        return;
      }

      // Update password
      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );

      // Clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Reset strength indicators
      passwordStrength.value = 0.0;
      passwordStrengthText.value = '';
      passwordStrengthColor.value = Colors.grey;

      // Show success message
      TSnackBar.showSuccess(
        message: 'Password changed successfully',
        title: 'Success',
      );

      // Navigate back
      Get.back();
    } catch (e) {
      TSnackBar.showError(
        message: 'Failed to change password: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
      //printnt('Password change process completed');
    }
  }
}
