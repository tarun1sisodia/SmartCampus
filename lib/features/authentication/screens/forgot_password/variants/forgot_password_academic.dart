import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ForgotPasswordAcademic extends StatelessWidget {
  const ForgotPasswordAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
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
              _buildScholarForm(controller, inkColor),
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
          child: Icon(Iconsax.password_check, color: color.withOpacity(0.4), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF2D2E32), letterSpacing: 0, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        const Text('Formal Credential Recovery Protocol', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF2D2E32), letterSpacing: 0.5, fontFamily: 'Serif')),
        const SizedBox(height: 24),
        const Text(
          'Provide your registered identity locator to receive an official session reset link.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFF2D2E32), height: 1.6, fontFamily: 'Serif'),
        ),
      ],
    );
  }

  Widget _buildScholarForm(ForgotPasswordController controller, Color color) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: color.withOpacity(0.1), width: 1)),
            ),
            child: TextFormField(
              controller: controller.email,
              style: const TextStyle(color: Color(0xFF2D2E32), fontFamily: 'Serif'),
              validator: (value) => value!.isEmpty ? 'Field required' : null,
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right, color: color.withOpacity(0.4), size: 22),
                hintText: 'Institutional Email Address',
                hintStyle: TextStyle(fontSize: 14, color: color.withOpacity(0.2), fontFamily: 'Serif'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              ),
            ),
          ),
          const SizedBox(height: 72),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.sendPasswordResetEmail(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
              child: const Text('Authorize Reset Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
            ),
          ),
        ],
      ),
    );
  }
}
