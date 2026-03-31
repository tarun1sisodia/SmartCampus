import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ForgotPasswordNeumorphism extends StatelessWidget {
  const ForgotPasswordNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
    const bgColor = Color(0xFFE0E5EC);

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildNeuHeader(bgColor),
              const SizedBox(height: 72),
              _buildNeuForm(controller, bgColor),
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
          child: const Icon(Iconsax.password_check, color: Color(0xFFA3B1C6), size: 48),
        ),
        const SizedBox(height: 48),
        const Text('Gatekeeper', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF4D565F), letterSpacing: -1)),
        const SizedBox(height: 12),
        const Text('SECURE_TACTILE_RECOVERY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2)),
        const SizedBox(height: 24),
        const Text(
          'Input your institutional locator to receive session recovery instructions.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFA3B1C6), height: 1.6, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildNeuForm(ForgotPasswordController controller, Color bgColor) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
              ],
            ),
            child: TextFormField(
              controller: controller.email,
              validator: (value) => value!.isEmpty ? 'LOCATOR_REQUIRED' : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right, color: Color(0xFFA3B1C6), size: 22),
                hintText: 'EMAIL ADDRESS',
                hintStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFA3B1C6), letterSpacing: 1),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              ),
            ),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => controller.sendPasswordResetEmail(),
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
              child: const Center(child: Text('LOG_RECOVERY_INIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4D565F), letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }
}
