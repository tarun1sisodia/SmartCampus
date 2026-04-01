import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/change_password_controller.dart';

class ChangePasswordNeumorphism extends StatelessWidget {
  const ChangePasswordNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
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
          child: const Icon(Iconsax.shield_security, color: Color(0xFFA3B1C6), size: 48),
        ),
        const SizedBox(height: 48),
        const Text('Vault Update', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF4D565F), letterSpacing: -1)),
        const SizedBox(height: 12),
        const Text('SECURE_TACTILE_ROTATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuForm(ChangePasswordController controller, Color bgColor) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildNeuField(controller.newPassword, 'NEW_IDENTITY_KEY', bgColor, controller),
          const SizedBox(height: 16),
          _buildNeuField(controller.confirmPassword, 'CONFIRM_IDENTITY_KEY', bgColor, controller),
          const SizedBox(height: 56),
          GestureDetector(
            onTap: () => controller.updatePassword(),
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
              child: const Center(child: Text('FINALIZE_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4D565F), letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuField(TextEditingController textController, String label, Color bgColor, ChangePasswordController controller) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
          BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
        ],
      ),
      child: TextFormField(
        controller: textController,
        obscureText: controller.hidePassword.value,
        validator: (value) => value!.isEmpty ? 'MANDATORY' : null,
        decoration: InputDecoration(
          prefixIcon: const Icon(Iconsax.password_check, color: Color(0xFFA3B1C6), size: 22),
          suffixIcon: IconButton(
            onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
            icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFFA3B1C6), size: 20),
          ),
          hintText: label.toUpperCase(),
          hintStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFA3B1C6), letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    ));
  }
}
