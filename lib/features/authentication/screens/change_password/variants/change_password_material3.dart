import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../change_password_controller.dart';

class ChangePasswordMaterial3 extends StatelessWidget {
  const ChangePasswordMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildM3Header(theme),
              const SizedBox(height: 56),
              _buildM3Form(controller, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(32)),
          child: Icon(Iconsax.shield_security, color: theme.colorScheme.secondary, size: 48),
        ),
        const SizedBox(height: 32),
        Text('Reset Password', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -1)),
        const SizedBox(height: 12),
        Text('Secure your account with a new identity key.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Form(ChangePasswordController controller, ThemeData theme) {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        children: [
          _buildM3Field(controller.newPassword, 'New Password', theme, controller),
          const SizedBox(height: 16),
          _buildM3Field(controller.confirmPassword, 'Confirm Password', theme, controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => controller.updatePassword(),
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.secondary, foregroundColor: theme.colorScheme.onSecondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildM3Field(TextEditingController textController, String label, ThemeData theme, ChangePasswordController controller) {
    return Obx(() => TextFormField(
      controller: textController,
      obscureText: controller.hidePassword.value,
      validator: (value) => value!.isEmpty ? 'Field required' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(Iconsax.password_check, color: theme.colorScheme.secondary, size: 22),
        suffixIcon: IconButton(
          onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
          icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: theme.colorScheme.onSurfaceVariant, size: 20),
        ),
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.secondary), borderRadius: BorderRadius.circular(16)),
      ),
    ));
  }
}
