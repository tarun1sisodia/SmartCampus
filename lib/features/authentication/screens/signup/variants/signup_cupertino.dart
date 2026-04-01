import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupCupertino extends StatelessWidget {
  const SignupCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildIosLogo(),
              const SizedBox(height: 56),
              _buildIosForm(controller),
              const SizedBox(height: 48),
              _buildIosSocial(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIosLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 10))]),
          child: const Icon(CupertinoIcons.person_add_solid, color: Color(0xFF007AFF), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1, color: Color(0xFF000000))),
        const SizedBox(height: 8),
        const Text('Institutional Enrollment Protocol', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildIosForm(SignupController controller) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _iosTextField(controller.firstName, 'First Name')),
                    const SizedBox(height: 44, child: VerticalDivider(width: 1, color: Color(0xFFF2F2F7))),
                    Expanded(child: _iosTextField(controller.lastName, 'Last Name')),
                  ],
                ),
                const Divider(indent: 16, height: 1, color: Color(0xFFF2F2F7)),
                _iosTextField(controller.username, 'Username', icon: CupertinoIcons.person_fill),
                const Divider(indent: 16, height: 1, color: Color(0xFFF2F2F7)),
                _iosTextField(controller.email, 'Email Address', icon: CupertinoIcons.mail_solid),
                const Divider(indent: 16, height: 1, color: Color(0xFFF2F2F7)),
                _iosTextField(controller.phoneNumber, 'Phone Number', icon: CupertinoIcons.phone_fill),
                const Divider(indent: 16, height: 1, color: Color(0xFFF2F2F7)),
                Obx(() => _iosTextField(
                  controller.password,
                  'Password',
                  icon: CupertinoIcons.lock_fill,
                  obscure: controller.hidePassword.value,
                  suffix: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                    child: Icon(controller.hidePassword.value ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill, color: const Color(0xFF8E8E93), size: 20),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildIosTerms(controller),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: () => controller.signup(),
              child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iosTextField(TextEditingController textController, String hint, {IconData? icon, bool obscure = false, Widget? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF007AFF), size: 22) : null,
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 17, color: Color(0xFFC7C7CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildIosTerms(SignupController controller) {
    return Obx(() => Row(
      children: [
        CupertinoSwitch(
          value: controller.privacyPolicy.value,
          onChanged: (value) => controller.privacyPolicy.value = value,
          activeTrackColor: const Color(0xFF34C759),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('I agree to the Institutional Terms.', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)))),
      ],
    ));
  }

  Widget _buildIosSocial(SignupController controller) {
    return Column(
      children: [
        const Text('or register via', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            onPressed: () => controller.signInWithGoogle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(TImageStrings.google, width: 22),
                const SizedBox(width: 12),
                const Text('Register with Google', style: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.normal, fontSize: 17)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
