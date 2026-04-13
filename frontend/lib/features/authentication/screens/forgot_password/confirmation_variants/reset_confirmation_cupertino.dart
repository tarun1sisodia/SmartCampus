import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/forgot_password_controller.dart';

class ResetConfirmationCupertino extends StatelessWidget {
  const ResetConfirmationCupertino({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildIosHeader(),
              const SizedBox(height: 56),
              _buildIosData(email),
              const SizedBox(height: 48),
              _buildIosActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 10))]),
          child: const Icon(CupertinoIcons.paperplane_fill, color: Color(0xFF007AFF), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('Email Dispatched', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1, color: Color(0xFF000000))),
        const SizedBox(height: 8),
        const Text('Institutional Security Uplink Success', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildIosData(String email) {
    return Column(
      children: [
        Text(email, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Color(0xFF000000))),
        const SizedBox(height: 24),
        const Text(
          'We have transmitted an encrypted reset link. Access your communication node to proceed with credential restoration.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildIosActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CupertinoButton.filled(
            borderRadius: BorderRadius.circular(14),
            onPressed: () => Get.back(),
            child: const Text('Acknowledged', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
          ),
        ),
        const SizedBox(height: 24),
        CupertinoButton(
          onPressed: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: const Text('Resend Transmission', style: TextStyle(fontSize: 17, color: Color(0xFF007AFF))),
        ),
      ],
    );
  }
}
