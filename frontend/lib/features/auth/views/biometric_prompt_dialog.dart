import 'package:flutter/material.dart';
import '../../../core/services/biometric_service.dart';
import '../../../app/dependency_injection.dart';

class BiometricPromptDialog extends StatelessWidget {
  const BiometricPromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final biometricService = getIt<BiometricService>();

    return AlertDialog(
      title: const Text('Biometric Login'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fingerprint, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Use your fingerprint or face to login safely.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () async {
            final authenticated = await biometricService.authenticate();
            if (authenticated) {
              // TODO: Handle biometric success (usually requires a stored token refresh)
              if (context.mounted) Navigator.pop(context, true);
            }
          },
          child: const Text('AUTHENTICATE'),
        ),
      ],
    );
  }
}
