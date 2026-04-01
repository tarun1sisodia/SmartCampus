import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class LoginFluent extends StatelessWidget {
  const LoginFluent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    const fluentBg = Color(0xFFF3F3F3);
    const accentColor = Color(0xFF0078D4);

    return Container(
      color: fluentBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
          child: Column(
            children: [
              _buildFluentLogo(accentColor),
              const SizedBox(height: 56),
              _buildFluentForm(controller, accentColor),
              const SizedBox(height: 48),
              _buildFluentSocial(controller, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFluentLogo(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 20))],
          ),
          child: Icon(Iconsax.security_user, color: color, size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text('Secure Access Framework', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF605E5C), letterSpacing: 0)),
      ],
    );
  }

  Widget _buildFluentForm(LoginController controller, Color color) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          _fluentTextField(controller.email, Iconsax.direct_right, 'Institutional Email'),
          const SizedBox(height: 16),
          Obx(() => _fluentTextField(
            controller.password,
            Iconsax.password_check,
            'Security Key',
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: color.withValues(alpha: 0.4), size: 20),
            ),
          )),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.emailAndPasswordSignIn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Initialize Authorization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fluentTextField(TextEditingController textController, IconData icon, String hint, {bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0078D4), size: 22),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildFluentSocial(LoginController controller, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.1))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('External Authentication', style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.3)))),
            Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.1))),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => controller.signInWithGoogle(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              foregroundColor: const Color(0xFF201F1E),
            ),
            icon: Image.network(TImageStrings.google, width: 22),
            label: const Text('Azure Active Directory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
