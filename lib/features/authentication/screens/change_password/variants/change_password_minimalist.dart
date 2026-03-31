import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../change_password_controller.dart';

class ChangePasswordMinimalist extends StatelessWidget {
  const ChangePasswordMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

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
        const Icon(Iconsax.shield_security, color: Colors.black12, size: 64),
        const SizedBox(height: 32),
        const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.black87, letterSpacing: -1.5)),
        const SizedBox(height: 12),
        const Text('Updating your security identity.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildMinimalForm(ChangePasswordController controller) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildMinimalField(controller.newPassword, 'New Password', controller),
          const SizedBox(height: 16),
          _buildMinimalField(controller.confirmPassword, 'Confirm Password', controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.updatePassword(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalField(TextEditingController textController, String hint, ChangePasswordController controller) {
    return Obx(() => TextFormField(
      controller: textController,
      obscureText: controller.hidePassword.value,
      validator: (value) => value!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black12),
        filled: true,
        fillColor: const Color(0xFFFBFBFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFF5F5F5)), borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(16)),
        suffixIcon: IconButton(
          onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
          icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.black12, size: 20),
        ),
      ),
    ));
  }
}
