import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginCupertino extends StatelessWidget {
  const LoginCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))]),
          child: const Icon(CupertinoIcons.shield_lefthalf_fill, color: Color(0xFF007AFF), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1, color: Color(0xFF000000))),
        const SizedBox(height: 8),
        const Text('Institutional Security Uplink', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildIosForm(LoginController controller) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _iosTextField(controller.email, CupertinoIcons.mail_solid, 'Email Address'),
                const Divider(indent: 52, height: 1, color: Color(0xFFF2F2F7)),
                Obx(() => _iosTextField(
                  controller.password,
                  CupertinoIcons.lock_fill,
                  'Password',
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
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: () => controller.emailAndPasswordSignIn(),
              child: const Text('Authorize Access', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iosTextField(TextEditingController textController, IconData icon, String hint, {bool obscure = false, Widget? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF007AFF), size: 22),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 17, color: Color(0xFFC7C7CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildIosSocial(LoginController controller) {
    return Column(
      children: [
        const Text('or continue with', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
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
                const Text('Sign in with Google', style: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.normal, fontSize: 17)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
