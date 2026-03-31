import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ForgotPasswordCupertino extends StatelessWidget {
  const ForgotPasswordCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildIosHeader(),
              const SizedBox(height: 56),
              _buildIosForm(controller),
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
          child: const Icon(CupertinoIcons.lock_shield_fill, color: Color(0xFFFF9500), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1, color: Color(0xFF000000))),
        const SizedBox(height: 8),
        const Text('Security Recovery Protocol', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Enter your registered email to receive an institutional reset link.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
          ),
        ),
      ],
    );
  }

  Widget _buildIosForm(ForgotPasswordController controller) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: controller.email,
                validator: (value) => value!.isEmpty ? 'Field required' : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.mail_solid, color: Color(0xFFFF9500), size: 22),
                  hintText: 'Email Address',
                  hintStyle: TextStyle(fontSize: 17, color: Color(0xFFC7C7CC)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFFF9500),
              onPressed: () => controller.sendPasswordResetEmail(),
              child: const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }
}
