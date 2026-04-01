import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../services/google_sign_in_service.dart';
import '../../../services/storage_service.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;
  final passwordVisible = false.obs;
  final isGoogleLoading = false.obs;

  // --- UI Facade Getters ---
  GlobalKey<FormState> get loginFormKey => formKey;
  TextEditingController get email => emailController;
  TextEditingController get password => passwordController;
  RxBool get hidePassword => passwordVisible;

  // --- UI Facade Methods ---
  void emailAndPasswordSignIn() => login();

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

      if (email != null) {
        emailController.text = email;
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
      StorageService.instance.saveUserCredentials(emailController.text.trim());
      //printnt('Credentials saved: email=${emailController.text}');
      // Show a confirmation message
      TSnackBar.showInfo(
        message: TTexts.rememberMeMessage,
        title: TTexts.rememberMe,
      );
    } else {
      // Clear saved credentials
      StorageService.instance.clearUserCredentials();
      //printnt('Credentials cleared');
      // Show a confirmation message
      TSnackBar.showInfo(
        message: TTexts.credentialsNOtSaved,
        title: TTexts.rememberMe,
      );
    }
  }

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final googleSignInService = Get.find<GoogleSignInService>();
      final user = await googleSignInService.signInWithGoogle();
      if (user != null) {
        Get.offAllNamed('/dashboard');
        return;
      }

      TSnackBar.showError(
        message: TTexts.googleError,
        title: TTexts.error,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(
        message: TTexts.errorOccured + e.toString(),
        title: TTexts.error,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  bool isUserLoggedIn() {
    final email = StorageService.instance.getUserEmail();
    final loggedIn = email != null;
    //printnt('Is user logged in? $loggedIn');
    return loggedIn;
  }

  void login() async {
    //printnt('Attempting to log in...');
    try {
      // Your login logic here
      if (rememberMe.value) {
        StorageService.instance.saveUserCredentials(emailController.text.trim());
        //printnt('Credentials saved during login: email=${emailController.text}');
      }

      // Show success message
      TSnackBar.showSuccess(
        message: TTexts.loginSuccess,
        title: TTexts.welcomeback,
      );
      //printnt('Login successful');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //printnt('Login failed: $e');
      // Determine if it's a server error or client error
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        TSnackBar.showNetworkError();
      } else if (e.toString().contains('auth') ||
          e.toString().contains('credentials')) {
        TSnackBar.showAuthError(
          message: TTexts.accountNotFound,
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
