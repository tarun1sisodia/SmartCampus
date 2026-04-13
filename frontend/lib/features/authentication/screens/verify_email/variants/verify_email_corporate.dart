import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailCorporate extends StatelessWidget {
  const VerifyEmailCorporate({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

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
              _buildCorporateActions(controller),
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
          child: const Icon(Iconsax.direct_send, color: Color(0xFF0F172A), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('IDENTITY_VERIFICATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text('INITIATE_ACCOUNT_VALIDATION_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildCorporateData(String? email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
      child: Column(
        children: [
          const Text('VERIFICATION_TARGET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(email?.toUpperCase() ?? 'IDENTITY_PENDING', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A), letterSpacing: 0.5)),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),
          const Text(
            'PROTOCOL_INSTRUCTION: VERIFY_YOUR_ACCOUNT_VIA_THE_INSTITUTIONAL_LINK_DISPATCHED_TO_YOUR_INBOX.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF94A3B8), height: 1.6, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateActions(SignupController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => controller.checkEmailVerificationStatus(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('CHECK_VALIDATION_STATUS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => controller.sendEmailVerification(),
          child: const Text('RE_DISPATCH_VERIFICATION_VECTOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1)),
        ),
      ],
    );
  }
}
