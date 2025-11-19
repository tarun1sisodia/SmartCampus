import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService extends GetxController {
  final LocalAuthentication _auth = LocalAuthentication();
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxBool isAvailable = false.obs;
  final RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;

  bool get isLinux {
    try {
      return Platform.isLinux;
    } catch (e) {
      // print("Error checking platform: $e");
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (!isLinux) {
      _loadBiometricSettings();
      checkBiometricAvailability();
    } else {
      // On Linux, set as not available
      isAvailable.value = false;
    }
  }

  Future<void> _loadBiometricSettings() async {
    if (isLinux) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      isBiometricEnabled.value = prefs.getBool('biometric_enabled') ?? false;
    } catch (e) {
      print("Error loading biometric settings: $e");
      isBiometricEnabled.value = false;
    }
  }

  Future<void> saveBiometricSettings(bool enabled) async {
    if (isLinux) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', enabled);
      isBiometricEnabled.value = enabled;
    } catch (e) {
      print("Error saving biometric settings: $e");
    }
  }

  Future<void> disableBiometrics() async {
    if (isLinux) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', false);
      isBiometricEnabled.value = false;
    } catch (e) {
      print("Error disabling biometrics: $e");
    }
  }

  Future<void> checkBiometricAvailability() async {
    if (isLinux) {
      isAvailable.value = false;
      return;
    }

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
    if (isLinux) return 'Device Authentication';

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
    if (isLinux) return true;

    if (!isAvailable.value) {
      await checkBiometricAvailability();
      if (!isAvailable.value) {
        Get.snackbar(
          'Not Available',
          'Biometric authentication is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true; // Return true to allow access even if biometrics aren't available
      }
    }

    try {
      isAuthenticating.value = true;

      final String reason = customReason ??
          'Please authenticate to access ${getBiometricTypeString() == 'Face ID' ? 'using Face ID' : 'using your fingerprint'}';

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        // stickyAuth: true,
        // useErrorDialogs: true,
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      String errorMessage = 'Authentication failed';

      if (e.code == 'NotAvailable') {
        errorMessage = 'Biometric authentication is not available';
      } else if (e.code == 'NotEnrolled') {
        errorMessage = 'No biometrics enrolled on this device';
      } else if (e.code == 'LockedOut') {
        errorMessage =
            'Biometric authentication is temporarily locked (too many attempts)';
      } else if (e.code == 'PermanentlyLockedOut') {
        errorMessage = 'Biometric authentication is permanently locked';
      }

      Get.snackbar(
        'Authentication Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Return true on error to allow access rather than blocking
      return true;
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> cancelAuthentication() async {
    if (isLinux) return;

    try {
      await _auth.stopAuthentication();
      isAuthenticating.value = false;
    } on PlatformException catch (e) {
      debugPrint('Error cancelling authentication: ${e.message}');
    }
  }
}
