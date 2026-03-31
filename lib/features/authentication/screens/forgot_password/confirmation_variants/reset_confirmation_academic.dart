import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ResetConfirmationAcademic extends StatelessWidget {
  const ResetConfirmationAcademic({super.key, required this.email});

  final String email;

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
              const SizedBox(height: 56),
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
          child: Icon(Icons.mark_email_read_outlined, color: color.withOpacity(0.4), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF2D2E32), letterSpacing: 0, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        const Text('Formal Security Dispatch Success', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF2D2E32), letterSpacing: 0.5, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarData(String email, Color color) {
    return Column(
      children: [
        Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D2E32), fontFamily: 'Serif')),
        const SizedBox(height: 24),
        const Text(
          'We have transmitted an official credential restoration link. Please access your institutional inbox to proceed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFF2D2E32), height: 1.6, fontFamily: 'Serif'),
        ),
      ],
    );
  }

  Widget _buildScholarActions(Color color) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            child: const Text('Protocol Acknowledged', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: Text('Re-dispatch Communication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color.withOpacity(0.5), fontFamily: 'Serif')),
        ),
      ],
    );
  }
}
