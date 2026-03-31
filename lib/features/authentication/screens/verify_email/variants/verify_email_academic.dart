import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailAcademic extends StatelessWidget {
  const VerifyEmailAcademic({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);

    return Container(
      color: paperColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
          child: Column(
            children: [
              _buildScholarHeader(inkColor),
              const SizedBox(height: 72),
              _buildScholarData(email, inkColor),
              const SizedBox(height: 48),
              _buildScholarActions(inkColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScholarHeader(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: color.withOpacity(0.05)), shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Icon(Iconsax.direct_send, color: color.withOpacity(0.4), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF2D2E32), letterSpacing: 0, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        const Text('Formal Identity Verification Protocol', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF2D2E32), letterSpacing: 0.5, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarData(String? email, Color color) {
    return Column(
      children: [
        Text(email ?? 'Your Identity Node', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D2E32), fontFamily: 'Serif')),
        const SizedBox(height: 24),
        Text(
          'An institutional validation link has been transmitted. Please verify your membership via the instructions in your inbox.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: color.withOpacity(0.5), fontFamily: 'Serif', height: 1.6),
        ),
      ],
    );
  }

  Widget _buildScholarActions(Color color) {
    final controller = Get.put(SignupController());

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => controller.checkEmailVerificationStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            child: const Text('Authorize Membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => controller.sendEmailVerification(),
          child: Text('Re-transmit Protocol link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color.withOpacity(0.5), fontFamily: 'Serif')),
        ),
      ],
    );
  }
}
