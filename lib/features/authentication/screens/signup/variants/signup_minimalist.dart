import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupMinimalist extends StatelessWidget {
  const SignupMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              _buildMinimalLogo(),
              const SizedBox(height: 56),
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
        const Icon(Iconsax.user_octagon, color: Colors.black12, size: 64),
        const SizedBox(height: 32),
        const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.black87, letterSpacing: -1.5)),
        const SizedBox(height: 12),
        const Text('Welcome to your new classroom.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildMinimalForm(SignupController controller) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextFormField(controller: controller.firstName, decoration: _minimalInputDecoration('First Name'))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: controller.lastName, decoration: _minimalInputDecoration('Last Name'))),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(controller: controller.username, decoration: _minimalInputDecoration('Username', icon: Iconsax.user_edit)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.email, decoration: _minimalInputDecoration('Email Address', icon: Iconsax.direct)),
          const SizedBox(height: 16),
          TextFormField(controller: controller.phoneNumber, decoration: _minimalInputDecoration('Phone Number', icon: Iconsax.call)),
          const SizedBox(height: 16),
          Obx(() => TextFormField(
            controller: controller.password,
            obscureText: controller.hidePassword.value,
            decoration: _minimalInputDecoration(
              'Password',
              icon: Iconsax.password_check,
              suffix: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.black12, size: 20),
              ),
            ),
          )),
          const SizedBox(height: 24),
          _buildMinimalTerms(controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _minimalInputDecoration(String hint, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.black12, size: 20) : null,
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

  Widget _buildMinimalTerms(SignupController controller) {
    return Obx(() => Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: controller.privacyPolicy.value,
            onChanged: (value) => controller.privacyPolicy.value = value!,
            checkColor: Colors.white,
            activeColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('I agree to the Terms and Privacy Policy.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26))),
      ],
    ));
  }

  Widget _buildMinimalSocial(SignupController controller) {
    return Column(
      children: [
        const Text('or register via', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black12)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF5F5F5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), foregroundColor: Colors.black87),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
