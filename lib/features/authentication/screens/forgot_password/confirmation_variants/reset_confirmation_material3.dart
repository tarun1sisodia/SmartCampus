import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ResetConfirmationMaterial3 extends StatelessWidget {
  const ResetConfirmationMaterial3({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
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
              _buildM3Data(email, theme),
              const SizedBox(height: 48),
              _buildM3Actions(theme),
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
          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(32)),
          child: Icon(Icons.mark_email_read_outlined, color: theme.colorScheme.primary, size: 48),
        ),
        const SizedBox(height: 32),
        Text('Email Sent', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -1)),
        const SizedBox(height: 12),
        Text('Password Reset Link Sent', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Data(String email, ThemeData theme) {
    return Column(
      children: [
        Text(email, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 24),
        Text(
          'Your account security is our priority. We have sent a secure link to your email. Please follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildM3Actions(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => Get.back(),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: Text('Resend Email', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
