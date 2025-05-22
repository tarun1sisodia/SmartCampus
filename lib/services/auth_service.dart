import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService extends GetxController {
  final LocalAuthentication _auth = LocalAuthentication();
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxBool isAvailable = false.obs;
  final RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBiometricSettings();
    checkBiometricAvailability();
  }

  Future<void> _loadBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isBiometricEnabled.value = prefs.getBool('biometric_enabled') ?? false;
  }

  Future<void> saveBiometricSettings(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    isBiometricEnabled.value = enabled;
  }

  Future<void> disableBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', false);
    isBiometricEnabled.value = false;
  }

  Future<void> checkBiometricAvailability() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canCheckBiometrics || await _auth.isDeviceSupported();

      isAvailable.value = canAuthenticate;

      if (canCheckBiometrics) {
        final biometrics = await _auth.getAvailableBiometrics();
        availableBiometrics.assignAll(biometrics);
      }
    } on PlatformException catch (e) {
      debugPrint('Error checking biometric availability: ${e.message}');
      isAvailable.value = false;
    }
  }

  String getBiometricTypeString() {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Device Authentication';
  }

  Future<bool> authenticateWithBiometrics({String? customReason}) async {
    if (!isAvailable.value) {
      await checkBiometricAvailability();
      if (!isAvailable.value) {
        Get.snackbar(
          'Not Available',
          'Biometric authentication is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    try {
      isAuthenticating.value = true;

      final String reason = customReason ??
          'Please authenticate to access ${getBiometricTypeString() == 'Face ID' ? 'using Face ID' : 'using your fingerprint'}';

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      String errorMessage = 'Authentication failed';

      if (e.code == auth_error.notAvailable) {
        errorMessage = 'Biometric authentication is not available';
      } else if (e.code == auth_error.notEnrolled) {
        errorMessage = 'No biometrics enrolled on this device';
      } else if (e.code == auth_error.lockedOut) {
        errorMessage =
            'Biometric authentication is temporarily locked (too many attempts)';
      } else if (e.code == auth_error.permanentlyLockedOut) {
        errorMessage = 'Biometric authentication is permanently locked';
      }

      Get.snackbar(
        'Authentication Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> cancelAuthentication() async {
    try {
      await _auth.stopAuthentication();
      isAuthenticating.value = false;
    } on PlatformException catch (e) {
      debugPrint('Error cancelling authentication: ${e.message}');
    }
  }
}
