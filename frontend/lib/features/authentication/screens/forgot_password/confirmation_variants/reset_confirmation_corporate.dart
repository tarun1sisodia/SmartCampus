import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/forgot_password_controller.dart';

class ResetConfirmationCorporate extends StatelessWidget {
  const ResetConfirmationCorporate({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildCorporateHeader(),
              const SizedBox(height: 56),
              _buildCorporateData(email),
              const SizedBox(height: 48),
              _buildCorporateActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorporateHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 3)),
          child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF0F172A), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('UPLINK_DISPATCHED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text('SECURE_COMMUNICATION_VERIFIED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.green, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildCorporateData(String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
      child: Column(
        children: [
          const Text('RECIPIENT_NODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(email.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A), letterSpacing: 0.5)),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),
          const Text(
            'PROTOCOL_INSTRUCTION: FOLLOW_THE_ENCRYPTED_LINK_IN_YOUR_INBOX_TO_RE_ESTABLISH_CREDENTIALS.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF94A3B8), height: 1.6, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('ACKNOWLEDGE_&_CLOSE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: const Text('RESEND_COMMUNICATION_VECTOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1)),
        ),
      ],
    );
  }
}
