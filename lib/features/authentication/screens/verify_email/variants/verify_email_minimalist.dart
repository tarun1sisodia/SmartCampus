import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailMinimalist extends StatelessWidget {
  const VerifyEmailMinimalist({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              _buildMinimalHeader(),
              const SizedBox(height: 72),
              _buildMinimalData(email),
              const SizedBox(height: 48),
              _buildMinimalActions(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Column(
      children: [
        const Icon(Iconsax.direct_send, color: Colors.black12, size: 64),
        const SizedBox(height: 32),
        const Text('Verify Email', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.black87, letterSpacing: -1.5)),
        const SizedBox(height: 12),
        const Text('Finalize your institutional identity.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildMinimalData(String? email) {
    return Column(
      children: [
        Text(email ?? 'Your Email', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 24),
        const Text(
          'We have sent a verification link to your email. Please follow the instructions to secure your account.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildMinimalActions(SignupController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => controller.checkEmailVerificationStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Check Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => controller.sendEmailVerification(),
          child: const Text('Resend Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black26)),
        ),
      ],
    );
  }
}
