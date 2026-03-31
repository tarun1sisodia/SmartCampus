import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailCupertino extends StatelessWidget {
  const VerifyEmailCupertino({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

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
              const SizedBox(height: 72),
              _buildIosActions(controller),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))]),
          child: const Icon(CupertinoIcons.mail_solid, color: Color(0xFF007AFF), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1, color: Color(0xFF000000))),
        const SizedBox(height: 8),
        const Text('Identity Verification Protocol', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildIosData(String? email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          Text(email ?? 'Your identity handle', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF000000))),
          const SizedBox(height: 24),
          const Text(
            'Institutional validation protocol initiated. Please verify your identity via the secure link in your inbox.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildIosActions(SignupController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CupertinoButton.filled(
            borderRadius: BorderRadius.circular(14),
            onPressed: () => controller.checkEmailVerificationStatus(),
            child: const Text('Check Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CupertinoButton(
            onPressed: () => controller.sendEmailVerification(),
            child: const Text('Resend Email', style: TextStyle(fontSize: 17, color: Color(0xFF007AFF))),
          ),
        ),
      ],
    );
  }
}
