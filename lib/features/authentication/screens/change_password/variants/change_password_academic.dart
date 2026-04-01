import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/change_password_controller.dart';

class ChangePasswordAcademic extends StatelessWidget {
  const ChangePasswordAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
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
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: color.withValues(alpha: 0.05)), shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Icon(Iconsax.shield_security, color: color.withValues(alpha: 0.4), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF2D2E32), letterSpacing: 0, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        const Text('Formal Credential Rotation Protocol', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF2D2E32), letterSpacing: 0.5, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarForm(ChangePasswordController controller, Color color) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildScholarField(controller.newPassword, 'New Identity Secret', color, controller),
          const SizedBox(height: 16),
          _buildScholarField(controller.confirmPassword, 'Confirm Identity Secret', color, controller),
          const SizedBox(height: 72),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.updatePassword(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
              child: const Text('Authorize Secret Rotation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarField(TextEditingController textController, String label, Color color, ChangePasswordController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.1), width: 1)),
      ),
      child: Obx(() => TextFormField(
        controller: textController,
        obscureText: controller.hidePassword.value,
        style: const TextStyle(color: Color(0xFF2D2E32), fontFamily: 'Serif'),
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(Iconsax.password_check, color: color.withValues(alpha: 0.4), size: 22),
          suffixIcon: IconButton(
            onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
            icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: color.withValues(alpha: 0.2), size: 20),
          ),
          hintText: label,
          hintStyle: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.2), fontFamily: 'Serif'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      )),
    );
  }
}
