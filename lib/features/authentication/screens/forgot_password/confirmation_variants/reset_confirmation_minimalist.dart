import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/forgot_password_controller.dart';

class ResetConfirmationMinimalist extends StatelessWidget {
  const ResetConfirmationMinimalist({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
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
              _buildMinimalActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Column(
      children: [
        const Icon(Icons.mark_email_read_outlined, color: Colors.black12, size: 64),
        const SizedBox(height: 32),
        const Text('Email Sent', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.black87, letterSpacing: -1.5)),
        const SizedBox(height: 12),
        const Text('Check your inbox for the reset link.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildMinimalData(String email) {
    return Column(
      children: [
        Text(email, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 24),
        const Text(
          'We have sent a secure password reset link to your email. Please follow the instructions to regain access.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildMinimalActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: const Text('Resend Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black26)),
        ),
      ],
    );
  }
}
