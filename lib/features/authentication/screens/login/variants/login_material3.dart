import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginMaterial3 extends StatelessWidget {
  const LoginMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildM3Logo(theme),
              const SizedBox(height: 48),
              _buildM3Form(controller, theme),
              const SizedBox(height: 32),
              _buildM3Social(controller, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildM3Logo(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(32)),
          child: Icon(Iconsax.user_octagon, color: theme.colorScheme.primary, size: 48),
        ),
        const SizedBox(height: 32),
        Text('Login', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -1)),
        const SizedBox(height: 8),
        Text('Welcome back to SmartCampus.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Form(LoginController controller, ThemeData theme) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.email,
            validator: (value) => value!.isEmpty ? 'Email required' : null,
            decoration: _m3InputDecoration(theme, Iconsax.direct_right, 'Email Address'),
          ),
          const SizedBox(height: 20),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            validator: (value) => value!.isEmpty ? 'Password required' : null,
            decoration: _m3InputDecoration(
              theme,
              Iconsax.password_check,
              'Password',
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: theme.colorScheme.primary, size: 20),
              ),
            ),
          )),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => controller.emailAndPasswordSignIn(),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _m3InputDecoration(ThemeData theme, IconData icon, String hint, {Widget? suffix}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 22),
      suffixIcon: suffix,
      labelText: hint,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerLow,
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary), borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildM3Social(LoginController controller, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or continue with', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
            Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
