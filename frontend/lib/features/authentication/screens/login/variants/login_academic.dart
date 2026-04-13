import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginAcademic extends StatelessWidget {
  const LoginAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);

    return Container(
      color: paperColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
          child: Column(
            children: [
              _buildScholarLogo(inkColor),
              const SizedBox(height: 72),
              _buildScholarForm(controller, inkColor),
              const SizedBox(height: 48),
              _buildScholarSocial(controller, inkColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScholarLogo(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: color.withValues(alpha: 0.05)), shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Icon(Iconsax.edit_25, color: color.withValues(alpha: 0.4), size: 48),
        ),
        const SizedBox(height: 32),
        Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: color, letterSpacing: 0, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        Text('Scholarly Portal Authentication', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: color.withValues(alpha: 0.5), letterSpacing: 0.5, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarForm(LoginController controller, Color color) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          _scholarTextField(controller.email, Iconsax.direct_right, 'Institutional Email', color),
          const SizedBox(height: 24),
          Obx(() => _scholarTextField(
            controller.password,
            Iconsax.password_check,
            'Security Key',
            color,
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: color.withValues(alpha: 0.2), size: 20),
            ),
          )),
          const SizedBox(height: 56),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => controller.emailAndPasswordSignIn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
              child: const Text('Authorize Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scholarTextField(TextEditingController textController, IconData icon, String hint, Color color, {bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.1), width: 1)),
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        style: TextStyle(color: color, fontFamily: 'Serif'),
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color.withValues(alpha: 0.4), size: 22),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.2), fontFamily: 'Serif'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildScholarSocial(LoginController controller, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: color.withValues(alpha: 0.05))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('External Registry', style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.3), fontFamily: 'Serif'))),
            Expanded(child: Divider(color: color.withValues(alpha: 0.05))),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              foregroundColor: color,
            ),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Google Academic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Serif')),
          ),
        ),
      ],
    );
  }
}
