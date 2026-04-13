import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/change_password_controller.dart';

class ChangePasswordGlassmorphism extends StatelessWidget {
  const ChangePasswordGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _glassContainer(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  _buildGlassHeader(),
                  const SizedBox(height: 56),
                  _buildGlassForm(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
          child: const Icon(Iconsax.shield_security, color: Colors.white70, size: 48),
        ),
        const SizedBox(height: 24),
        const Text('Security Update', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 8),
        const Text('Ethereal Credential Rotation', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white54, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildGlassForm(ChangePasswordController controller) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildGlassField(controller.newPassword, 'New Password', controller),
          const SizedBox(height: 16),
          _buildGlassField(controller.confirmPassword, 'Confirm Password', controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.updatePassword(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
              ),
              child: const Text('Initialize Authorization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassField(TextEditingController textController, String hint, ChangePasswordController controller) {
    return Obx(() => TextFormField(
      controller: textController,
      obscureText: controller.hidePassword.value,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: (value) => value!.isEmpty ? 'Identity failure' : null,
      decoration: InputDecoration(
        prefixIcon: const Icon(Iconsax.password_check, color: Colors.white54, size: 22),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(24)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(24)),
        suffixIcon: IconButton(
          onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
          icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.white24, size: 20),
        ),
      ),
    ));
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
