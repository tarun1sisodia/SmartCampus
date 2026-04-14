import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access SmartCampus',
        biometricOnly: true,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric error: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }
}
