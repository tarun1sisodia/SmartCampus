import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ResetConfirmationNeumorphism extends StatelessWidget {
  const ResetConfirmationNeumorphism({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildNeuHeader(bgColor),
              const SizedBox(height: 56),
              _buildNeuData(email, bgColor),
              const SizedBox(height: 48),
              _buildNeuActions(bgColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeuHeader(Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(10, 10), blurRadius: 20),
            ],
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFFA3B1C6), size: 48),
        ),
        const SizedBox(height: 48),
        const Text('Email Sent', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF4D565F), letterSpacing: -1)),
        const SizedBox(height: 12),
        const Text('SECURE_TACTILE_VERIFICATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuData(String email, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12, inset: true),
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12, inset: true),
        ],
      ),
      child: Column(
        children: [
          Text(email, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF4D565F))),
          const SizedBox(height: 24),
          const Text(
            'We have initiated a secure password restoration protocol. Access your communication node to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFA3B1C6), height: 1.6, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuActions(Color bgColor) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
              ],
            ),
            child: const Center(child: Text('ACKNOWLEDGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4D565F), letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: const Text('RESEND_TRANSMISSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFFA3B1C6), letterSpacing: 2)),
        ),
      ],
    );
  }
}
