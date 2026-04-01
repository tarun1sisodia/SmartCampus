import 'package:flutter/material.dart';
import 'package:smart_campus/features/teacher/controllers/dashboard_controller.dart';

class BiometricOverlay extends StatelessWidget {
  final DashboardController dashboardController;
  final bool dark;

  const BiometricOverlay({
    super.key,
    required this.dashboardController,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dark ? Colors.black87 : Colors.white70,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 80,
              color: dark ? Colors.white : Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Biometric Authentication Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => dashboardController.authenticateWithBiometrics(),
              child: const Text('Authenticate Now'),
            ),
          ],
        ),
      ),
    );
  }
}
