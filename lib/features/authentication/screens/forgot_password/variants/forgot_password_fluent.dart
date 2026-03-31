import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ForgotPasswordFluent extends StatelessWidget {
  const ForgotPasswordFluent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
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
              _buildFluentForm(controller, accentColor),
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
          child: Icon(Iconsax.password_check, color: color, size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text('Unified Recovery Framework', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF605E5C), letterSpacing: 0)),
        const SizedBox(height: 24),
        const Text(
          'Provide your institutional email to begin the credential restoration process.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFF605E5C), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFluentForm(ForgotPasswordController controller, Color color) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: TextFormField(
              controller: controller.email,
              validator: (value) => value!.isEmpty ? 'Field required' : null,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.direct_right, color: Color(0xFF0078D4), size: 22),
                hintText: 'Work Email Address',
                hintStyle: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.2)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              ),
            ),
          ),
          const SizedBox(height: 56),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.sendPasswordResetEmail(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Initialize Restoration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
