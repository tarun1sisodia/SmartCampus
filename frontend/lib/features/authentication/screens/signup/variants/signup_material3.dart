import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupMaterial3 extends StatelessWidget {
  const SignupMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
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
          decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(32)),
          child: Icon(Iconsax.user_add, color: theme.colorScheme.secondary, size: 48),
        ),
        const SizedBox(height: 32),
        Text('Create Account', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -1)),
        const SizedBox(height: 8),
        Text('Join the SmartCampus educator network.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Form(SignupController controller, ThemeData theme) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextFormField(controller: controller.firstName, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _m3InputDecoration(theme, 'First Name'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: controller.lastName, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _m3InputDecoration(theme, 'Last Name'))),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(controller: controller.username, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _m3InputDecoration(theme, 'Username', icon: Iconsax.user_edit)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.email, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _m3InputDecoration(theme, 'Email Address', icon: Iconsax.direct)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.phoneNumber, validator: (v) => v!.isEmpty ? 'REQ' : null, decoration: _m3InputDecoration(theme, 'Phone Number', icon: Iconsax.call)),
          const SizedBox(height: 16),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            validator: (v) => v!.isEmpty ? 'REQ' : null,
            decoration: _m3InputDecoration(
              theme,
              'Password',
              icon: Iconsax.password_check,
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: theme.colorScheme.secondary, size: 20),
              ),
            ),
          )),
          const SizedBox(height: 24),
          _buildM3Terms(controller, theme),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => controller.signup(),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Create Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _m3InputDecoration(ThemeData theme, String hint, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.secondary, size: 22) : null,
      suffixIcon: suffix,
      labelText: hint,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerLow,
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.secondary), borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildM3Terms(SignupController controller, ThemeData theme) {
    return Obx(() => Row(
      children: [
        Checkbox(
          value: controller.privacyPolicy.value,
          onChanged: (value) => controller.privacyPolicy.value = value!,
          checkColor: theme.colorScheme.onSecondary,
          activeColor: theme.colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text('I agree to the Institutional Terms.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
      ],
    ));
  }

  Widget _buildM3Social(SignupController controller, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or register via', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
            Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), foregroundColor: theme.colorScheme.onSurface),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
