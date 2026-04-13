import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/change_password_controller.dart';

class ChangePasswordBrutalist extends StatelessWidget {
  const ChangePasswordBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);

    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildBrutalHeader(yellow),
              const SizedBox(height: 72),
              _buildBrutalForm(controller, orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalHeader(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [BoxShadow(color: color, offset: const Offset(12, 12))],
          ),
          child: const Icon(Iconsax.shield_security, color: Colors.black, size: 64),
        ),
        const SizedBox(height: 56),
        _stackText('NEW_SECRET', color, fontSize: 48),
        const SizedBox(height: 12),
        _brutalBadge('IDENTITY_KEY_ROTATION_ACTIVE'),
      ],
    );
  }

  Widget _stackText(String text, Color color, {double fontSize = 48}) {
    return Stack(
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1, foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = Colors.black)),
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1)),
      ],
    );
  }

  Widget _brutalBadge(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black, width: 2)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
    );
  }

  Widget _buildBrutalForm(ChangePasswordController controller, Color color) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildBrutalField(controller.newPassword, 'NEW_IDENTITY_KEY', controller),
          const SizedBox(height: 16),
          _buildBrutalField(controller.confirmPassword, 'CONFIRM_IDENTITY_KEY', controller),
          const SizedBox(height: 56),
          GestureDetector(
            onTap: () => controller.updatePassword(),
            child: Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
              ),
              child: const Center(child: Text('FINALIZE_SECRET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalField(TextEditingController textController, String label, ChangePasswordController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Obx(() => TextFormField(
        controller: textController,
        obscureText: controller.hidePassword.value,
        validator: (value) => value!.isEmpty ? 'MANDATORY' : null,
        decoration: InputDecoration(
          prefixIcon: const Icon(Iconsax.password_check, color: Colors.black, size: 28),
          suffixIcon: IconButton(
            onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
            icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.black, size: 22),
          ),
          hintText: label.toUpperCase(),
          hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        ),
      )),
    );
  }
}
