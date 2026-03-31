import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import '../change_password_controller.dart';

class ChangePasswordCupertino extends StatelessWidget {
  const ChangePasswordCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildIosHeader(),
              const SizedBox(height: 56),
              _buildIosForm(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))]),
          child: const Icon(CupertinoIcons.lock_shield_fill, color: Color(0xFF5856D6), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1, color: Color(0xFF000000))),
        const SizedBox(height: 8),
        const Text('Credential Rotation Protocol', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildIosForm(ChangePasswordController controller) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildIosField(controller.newPassword, 'New Password', controller),
          const SizedBox(height: 1),
          _buildIosField(controller.confirmPassword, 'Confirm Password', controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF5856D6),
              onPressed: () => controller.updatePassword(),
              child: const Text('Update Credentials', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIosField(TextEditingController textController, String hint, ChangePasswordController controller) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => TextFormField(
        controller: textController,
        obscureText: controller.hidePassword.value,
        validator: (value) => value!.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          prefixIcon: const Icon(CupertinoIcons.lock_fill, color: Color(0xFF5856D6), size: 22),
          suffixIcon: IconButton(
            onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
            icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFFC7C7CC), size: 20),
          ),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 17, color: Color(0xFFC7C7CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      )),
    );
  }
}
