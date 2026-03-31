import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginBrutalist extends StatelessWidget {
  const LoginBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildBrutalLogo(yellow),
              const SizedBox(height: 72),
              _buildBrutalForm(controller, orange),
              const SizedBox(height: 48),
              _buildBrutalSocial(controller, blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalLogo(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [BoxShadow(color: color, offset: const Offset(12, 12))],
          ),
          child: const Icon(Iconsax.user_octagon, color: Colors.black, size: 64),
        ),
        const SizedBox(height: 48),
        _stackText('GATE_IN', color, fontSize: 48),
        const SizedBox(height: 8),
        _brutalBadge('IDENTITY_CHECK_ACTIVE'),
      ],
    );
  }

  Widget _stackText(String text, Color color, {double fontSize = 48}) {
    return Stack(
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1, foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = Colors.black)),
        Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: fontSize, color: color, letterSpacing: -1)),
      ],
    );
  }

  Widget _brutalBadge(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black, width: 2)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
    );
  }

  Widget _buildBrutalForm(LoginController controller, Color color) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          _brutalTextField(controller.email, Iconsax.direct_right, 'Email Address'),
          const SizedBox(height: 24),
          Obx(() => _brutalTextField(
            controller.password,
            Iconsax.password_check,
            'Password',
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: Colors.black, size: 20),
            ),
          )),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => controller.emailAndPasswordSignIn(),
            child: Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
              ),
              child: const Center(child: Text('LOG_INIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brutalTextField(TextEditingController textController, IconData icon, String hint, {bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'MANDATORY' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black, size: 28),
          suffixIcon: suffix,
          hintText: hint.toUpperCase(),
          hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        ),
      ),
    );
  }

  Widget _buildBrutalSocial(LoginController controller, Color color) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.black, thickness: 4)),
            _brutalBadge('EXTERNAL_AUTH'),
            const Expanded(child: Divider(color: Colors.black, thickness: 4)),
          ],
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => controller.signInWithGoogle(),
          child: Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [BoxShadow(color: color, offset: const Offset(8, 8))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(TImageStrings.google, width: 24),
                const SizedBox(width: 16),
                const Text('GOOGLE_HUB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
