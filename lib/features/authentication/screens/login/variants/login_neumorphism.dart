import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginNeumorphism extends StatelessWidget {
  const LoginNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    const bgColor = Color(0xFFE0E5EC);

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildNeuLogo(bgColor),
              const SizedBox(height: 48),
              _buildNeuForm(controller, bgColor),
              const SizedBox(height: 32),
              _buildNeuSocial(controller, bgColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeuLogo(Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(10, 10), blurRadius: 20),
            ],
          ),
          child: const Icon(Iconsax.security_safe, color: Color(0xFFA3B1C6), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('Gatekeeper', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF4D565F), letterSpacing: -1)),
        const SizedBox(height: 8),
        const Text('SECURE_TACTILE_LOGIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuForm(LoginController controller, Color bgColor) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          _neuTextField(controller.email, Iconsax.direct_right, 'Email Address', bgColor),
          const SizedBox(height: 24),
          Obx(() => _neuTextField(
            controller.password,
            Iconsax.password_check,
            'Password',
            bgColor,
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: const Color(0xFFA3B1C6), size: 20),
            ),
          )),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => controller.emailAndPasswordSignIn(),
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                  BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
                ],
              ),
              child: const Center(child: Text('LOG_INITIALIZE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4D565F), letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _neuTextField(TextEditingController textController, IconData icon, String hint, Color bgColor, {bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
          BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
        ],
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFA3B1C6), size: 22),
          suffixIcon: suffix,
          hintText: hint.toUpperCase(),
          hintStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFA3B1C6), letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildNeuSocial(LoginController controller, Color bgColor) {
    return Column(
      children: [
        const Text('OR_SOCIAL_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFFA3B1C6), letterSpacing: 2)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => controller.signInWithGoogle(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(TImageStrings.google, width: 20),
                const SizedBox(width: 16),
                const Text('GOOGLE_CLOUD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF4D565F), letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
