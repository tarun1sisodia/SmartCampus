import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ForgotPasswordMinimalist extends StatelessWidget {
  const ForgotPasswordMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              _buildMinimalHeader(),
              const SizedBox(height: 72),
              _buildMinimalForm(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Column(
      children: [
        const Icon(Iconsax.password_check, color: Colors.black12, size: 64),
        const SizedBox(height: 32),
        const Text('Forgot Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.black87, letterSpacing: -1.5)),
        const SizedBox(height: 12),
        const Text('Enter your email to receive recovery instructions.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildMinimalForm(ForgotPasswordController controller) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.email,
            validator: (value) => value!.isEmpty ? 'Email required' : null,
            decoration: InputDecoration(
              hintText: 'Email Address',
              hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black12),
              filled: true,
              fillColor: const Color(0xFFFBFBFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFF5F5F5)), borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.sendPasswordResetEmail(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
