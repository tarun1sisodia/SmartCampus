import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginGlassmorphism extends StatelessWidget {
  const LoginGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

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
                  _buildGlassLogo(),
                  const SizedBox(height: 56),
                  _buildGlassForm(controller),
                  const SizedBox(height: 40),
                  _buildGlassSocial(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: const Icon(Iconsax.finger_scan, color: Colors.white70, size: 48),
        ),
        const SizedBox(height: 24),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 8),
        const Text('Ethereal Entrance Protocol', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white54, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildGlassForm(LoginController controller) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.email,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            validator: (value) => value!.isEmpty ? 'Email required' : null,
            decoration: _glassInputDecoration(Iconsax.direct_right, 'Email Address'),
          ),
          const SizedBox(height: 20),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            validator: (value) => value!.isEmpty ? 'Password required' : null,
            decoration: _glassInputDecoration(
              Iconsax.password_check,
              'Password',
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.white30, size: 20),
              ),
            ),
          )),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.emailAndPasswordSignIn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.2))),
              ),
              child: const Text('Initialize Uplink', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _glassInputDecoration(IconData icon, String hint, {Widget? suffix}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white54, size: 22),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white24),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(24)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildGlassSocial(LoginController controller) {
    return Column(
      children: [
        const Text('or authenticate via', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white30)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              foregroundColor: Colors.white70,
            ),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google Cloud', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
