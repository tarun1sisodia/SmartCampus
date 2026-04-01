import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/forgot_password_controller.dart';

class ForgotPasswordMaterial3 extends StatelessWidget {
  const ForgotPasswordMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
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
          decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(32)),
          child: Icon(Iconsax.password_check, color: theme.colorScheme.tertiary, size: 48),
        ),
        const SizedBox(height: 32),
        Text('Forgot Password', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -1)),
        const SizedBox(height: 12),
        Text('No worries. Enter your email and we\'ll send you instructions.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Form(ForgotPasswordController controller, ThemeData theme) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.email,
            validator: (value) => value!.isEmpty ? 'Email required' : null,
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.direct_right, color: theme.colorScheme.tertiary, size: 22),
              labelText: 'Email Address',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.tertiary), borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => controller.sendPasswordResetEmail(),
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.tertiary, foregroundColor: theme.colorScheme.onTertiary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
