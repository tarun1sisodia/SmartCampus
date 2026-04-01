import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/change_password_controller.dart';

class ChangePasswordCorporate extends StatelessWidget {
  const ChangePasswordCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

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
          child: const Icon(Iconsax.shield_security, color: Color(0xFF0F172A), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('CREDENTIAL_UPDATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text('INITIATE_PASSWORD_ROTATION_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildCorporateForm(ChangePasswordController controller) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCorporateField(controller.newPassword, 'NEW_IDENTITY_KEY', Iconsax.password_check, true, controller),
          const SizedBox(height: 16),
          _buildCorporateField(controller.confirmPassword, 'VERIFY_IDENTITY_KEY', Iconsax.password_check, true, controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.updatePassword(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: const Text('FINALIZE_ROTATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateField(TextEditingController textController, String label, IconData icon, bool isPassword, ChangePasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
        ),
        Obx(() => TextFormField(
          controller: textController,
          obscureText: isPassword ? controller.hidePassword.value : false,
          validator: (value) => value!.isEmpty ? 'FIELD_REQUIRED' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0F172A)),
            suffixIcon: isPassword ? IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFF0F172A)),
            ) : null,
            hintText: label.replaceAll('_', ' '),
            hintStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F172A), width: 2), borderRadius: BorderRadius.zero),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB), width: 2), borderRadius: BorderRadius.zero),
          ),
        )),
      ],
    );
  }
}
