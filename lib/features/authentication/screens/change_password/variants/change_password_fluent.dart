import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/change_password_controller.dart';

class ChangePasswordFluent extends StatelessWidget {
  const ChangePasswordFluent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 20))],
          ),
          child: Icon(Iconsax.shield_security, color: color, size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text('Unified Credential Management Success', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF605E5C), letterSpacing: 0)),
      ],
    );
  }

  Widget _buildFluentForm(ChangePasswordController controller, Color color) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildFluentField(controller.newPassword, 'New Identity Secret', color, controller),
          const SizedBox(height: 8),
          _buildFluentField(controller.confirmPassword, 'Confirm Identity Secret', color, controller),
          const SizedBox(height: 56),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.updatePassword(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Update Secret', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentField(TextEditingController textController, String label, Color color, ChangePasswordController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Obx(() => TextFormField(
        controller: textController,
        obscureText: controller.hidePassword.value,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: const Icon(Iconsax.password_check, color: Color(0xFF0078D4), size: 22),
          suffixIcon: IconButton(
            onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
            icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: color.withValues(alpha: 0.4), size: 20),
          ),
          hintText: label,
          hintStyle: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      )),
    );
  }
}
