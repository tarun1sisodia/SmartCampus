import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginCorporate extends StatelessWidget {
  const LoginCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCorporateLogo(),
              const SizedBox(height: 48),
              _buildCorporateForm(controller),
              const SizedBox(height: 32),
              _buildCorporateSocial(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorporateLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 3)),
          child: const Icon(Iconsax.security_user, color: Color(0xFF0F172A), size: 48),
        ),
        const SizedBox(height: 24),
        Text('CAMPUS_GATEWAY_V.1', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A), letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('SECURE_INSTITUTIONAL_UPLINK', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildCorporateForm(LoginController controller) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('USER_IDENTITY_PROTECTOR'),
          TextFormField(
            controller: controller.email,
            validator: (value) => value!.isEmpty ? 'IDENTITY_REQUIRED' : null,
            decoration: _corporateInputDecoration(Iconsax.direct_right, 'Email Address'),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('CREDENTIAL_ENCRYPTION_KEY'),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            validator: (value) => value!.isEmpty ? 'KEY_REQUIRED' : null,
            decoration: _corporateInputDecoration(
              Iconsax.password_check,
              'Password',
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFF0F172A)),
              ),
            ),
          )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.emailAndPasswordSignIn(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: const Text('AUTHORIZE_ACCESS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
    );
  }

  InputDecoration _corporateInputDecoration(IconData icon, String hint, {Widget? suffix}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF0F172A)),
      suffixIcon: suffix,
      hintText: hint.toUpperCase(),
      hintStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F172A), width: 2), borderRadius: BorderRadius.zero),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB), width: 2), borderRadius: BorderRadius.zero),
    );
  }

  Widget _buildCorporateSocial(LoginController controller) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 2)),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('SOCIAL_VECTOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8)))),
            Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 2)),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0F172A), width: 2), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            icon: Image.network(TImageStrings.google, width: 20),
            label: const Text('SIGN_IN_VIA_GOOGLE', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1)),
          ),
        ),
      ],
    );
  }
}
