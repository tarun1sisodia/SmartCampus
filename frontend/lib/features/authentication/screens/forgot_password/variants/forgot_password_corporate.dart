import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/forgot_password_controller.dart';

class ForgotPasswordCorporate extends StatelessWidget {
  const ForgotPasswordCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildCorporateHeader(),
              const SizedBox(height: 56),
              _buildCorporateForm(controller),
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
          child: const Icon(Iconsax.password_check, color: Color(0xFF0F172A), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('CREDENTIAL_RECOVERY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text('INITIATE_SECURE_RESET_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1.5)),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'PLEASE_ENTER_REGISTERED_IDENTITY_TO_RECEIVE_ENCRYPTED_RESET_CODE.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF94A3B8), height: 1.6, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildCorporateForm(ForgotPasswordController controller) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('IDENTITY_LOCATOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
          ),
          TextFormField(
            controller: controller.email,
            validator: (value) => value!.isEmpty ? 'LOCATOR_REQUIRED' : null,
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.direct_right, color: Color(0xFF0F172A)),
              hintText: 'EMAIL ADDRESS',
              hintStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1)),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F172A), width: 2), borderRadius: BorderRadius.zero),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB), width: 2), borderRadius: BorderRadius.zero),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.sendPasswordResetEmail(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: const Text('INITIALIZE_RESET_LINK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
