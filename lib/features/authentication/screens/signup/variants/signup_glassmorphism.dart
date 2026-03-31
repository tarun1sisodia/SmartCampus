import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupGlassmorphism extends StatelessWidget {
  const SignupGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

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
                  const SizedBox(height: 48),
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
          child: const Icon(Iconsax.user_tag, color: Colors.white70, size: 48),
        ),
        const SizedBox(height: 24),
        const Text('Join SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 8),
        const Text('Ethereal Enrollment Protocol', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white54, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildGlassForm(SignupController controller) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextFormField(controller: controller.firstName, style: _glassStyle(), decoration: _glassInputDecoration('First Name'))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: controller.lastName, style: _glassStyle(), decoration: _glassInputDecoration('Last Name'))),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(controller: controller.username, style: _glassStyle(), decoration: _glassInputDecoration('Username', icon: Iconsax.user_edit)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.email, style: _glassStyle(), decoration: _glassInputDecoration('Email Address', icon: Iconsax.direct)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.phoneNumber, style: _glassStyle(), decoration: _glassInputDecoration('Phone Number', icon: Iconsax.call)),
          const SizedBox(height: 16),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            style: _glassStyle(),
            decoration: _glassInputDecoration(
              'Password',
              icon: Iconsax.password_check,
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.white30, size: 20),
              ),
            ),
          )),
          const SizedBox(height: 24),
          _buildGlassTerms(controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.2))),
              ),
              child: const Text('Initialize Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _glassStyle() => const TextStyle(color: Colors.white, fontSize: 15);

  InputDecoration _glassInputDecoration(String hint, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.white54, size: 22) : null,
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

  Widget _buildGlassTerms(SignupController controller) {
    return Obx(() => Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: controller.privacyPolicy.value,
            onChanged: (value) => controller.privacyPolicy.value = value!,
            checkColor: Colors.white,
            activeColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('Agreement to Institutional Terms', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white54))),
      ],
    ));
  }

  Widget _buildGlassSocial(SignupController controller) {
    return Column(
      children: [
        const Text('or authenticate via', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white30)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), foregroundColor: Colors.white70),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google Cloud Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
