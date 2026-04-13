import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/services/biometric_service.dart';
import '../../../app/dependency_injection.dart';
import '../../../common/utils/constants/colors.dart';

class BiometricPromptDialog extends StatelessWidget {
  const BiometricPromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final biometricService = getIt<BiometricService>();

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
      backgroundColor: Colors.white,
      title: const Text('BIOMETRIC ACCESS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.finger_scan, size: 64, color: TColors.executiveNavy),
          SizedBox(height: 24),
          Text(
            'PLEASE AUTHENTICATE TO ACCESS THE SECURE PROFESSOR PORTAL.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: TColors.slate600, letterSpacing: 0.5),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900)),
        ),
        ElevatedButton(
          onPressed: () async {
            final authenticated = await biometricService.authenticate();
            if (authenticated) {
              if (context.mounted) Navigator.pop(context, true);
            }
          },
          child: const Text('AUTHENTICATE'),
        ),
      ],
    );
  }
}
