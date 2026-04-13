import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginMinimalist extends StatelessWidget {
  const LoginMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              _buildMinimalLogo(),
              const SizedBox(height: 72),
              _buildMinimalForm(controller),
              const SizedBox(height: 48),
              _buildMinimalSocial(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalLogo() {
    return Column(
      children: [
        const Icon(Iconsax.user_tag, color: Colors.black12, size: 64),
        const SizedBox(height: 32),
        const Text('Welcome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.black87, letterSpacing: -1.5)),
        const SizedBox(height: 12),
        const Text('Please sign in to continue.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildMinimalForm(LoginController controller) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.email,
            validator: (value) => value!.isEmpty ? 'Email required' : null,
            decoration: _minimalInputDecoration('Email Address'),
          ),
          const SizedBox(height: 24),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            validator: (value) => value!.isEmpty ? 'Password required' : null,
            decoration: _minimalInputDecoration(
              'Password',
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.black12, size: 20),
              ),
            ),
          )),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.emailAndPasswordSignIn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _minimalInputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black12),
      filled: true,
      fillColor: const Color(0xFFFBFBFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFF5F5F5)), borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildMinimalSocial(LoginController controller) {
    return Column(
      children: [
        const Text('or continue with', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black12)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFF5F5F5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              foregroundColor: Colors.black87,
            ),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
