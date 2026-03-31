import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailFluent extends StatelessWidget {
  const VerifyEmailFluent({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    const accentColor = Color(0xFF0078D4);

    return Container(
      color: fluentBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
          child: Column(
            children: [
              _buildFluentHeader(accentColor),
              const SizedBox(height: 56),
              _buildFluentData(email, accentColor),
              const SizedBox(height: 48),
              _buildFluentActions(accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFluentHeader(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
          ),
          child: Icon(Iconsax.direct_send, color: color, size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text('Unified Identity Verification Protocol', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF605E5C), letterSpacing: 0)),
      ],
    );
  }

  Widget _buildFluentData(String? email, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(email ?? 'Your Identity Node', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF201F1E))),
          const SizedBox(height: 24),
          const Text(
            'Institutional validation protocol initiated. Please verify your membership via the secure link dispatched to your inbox.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFF605E5C), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentActions(Color color) {
    final controller = Get.put(SignupController());

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => controller.checkEmailVerificationStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Verify Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => controller.sendEmailVerification(),
          child: Text('Resend Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color.withOpacity(0.5))),
        ),
      ],
    );
  }
}
