import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../controllers/signup_controller.dart';
import '../../../../../common/utils/constants/image_strings.dart';

class SignupCyberpunk extends StatelessWidget {
  const SignupCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                children: [
                  _buildCyberLogo(cyan, magenta),
                  const SizedBox(height: 48),
                  _buildCyberForm(controller, cyan),
                  const SizedBox(height: 32),
                  _buildCyberSocial(controller, magenta),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color color) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(color: color.withOpacity(0.05)),
      ),
    );
  }

  Widget _buildCyberLogo(Color cyan, Color magenta) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: cyan, width: 2),
            boxShadow: [BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Icon(Iconsax.user_add, color: cyan, size: 48),
        ),
        const SizedBox(height: 32),
        Text('ENROLL_NODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: cyan, letterSpacing: 4, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Text('INITIALIZING_NEW_IDENTITY...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: magenta, letterSpacing: 2, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildCyberForm(SignupController controller, Color color) {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _cyberTextField(controller.firstName, 'First Name', color)),
              const SizedBox(width: 12),
              Expanded(child: _cyberTextField(controller.lastName, 'Last Name', color)),
            ],
          ),
          const SizedBox(height: 16),
          _cyberTextField(controller.username, 'Username', color, icon: Iconsax.user_edit),
          const SizedBox(height: 16),
          _cyberTextField(controller.email, 'Email Address', color, icon: Iconsax.direct),
          const SizedBox(height: 16),
          _cyberTextField(controller.phoneNumber, 'Phone Number', color, icon: Iconsax.call),
          const SizedBox(height: 16),
          Obx(() => _cyberTextField(
            controller.password,
            'Password',
            color,
            icon: Iconsax.password_check,
            obscure: controller.hidePassword.value,
            suffix: IconButton(
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
              icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye, color: color, size: 20),
            ),
          )),
          const SizedBox(height: 24),
          _buildCyberTerms(controller, color),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => controller.signup(),
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 2),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
              ),
              child: Center(child: Text('INITIALIZE_IDENTITY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color, letterSpacing: 2, fontFamily: 'Courier'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cyberTextField(TextEditingController textController, String hint, Color color, {IconData? icon, bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
        controller: textController,
        obscureText: obscure,
        style: TextStyle(color: color, fontFamily: 'Courier'),
        validator: (value) => value!.isEmpty ? 'MISSING' : null,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: color, size: 22) : null,
          suffixIcon: suffix,
          hintText: hint.toUpperCase(),
          hintStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withOpacity(0.3), letterSpacing: 2, fontFamily: 'Courier'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildCyberTerms(SignupController controller, Color color) {
    return Obx(() => GestureDetector(
      onTap: () => controller.privacyPolicy.value = !controller.privacyPolicy.value,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: controller.privacyPolicy.value ? color.withOpacity(0.2) : Colors.transparent,
              border: Border.all(color: color, width: 1),
            ),
            child: controller.privacyPolicy.value ? Icon(Icons.check, size: 16, color: color) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('AGREE_TO_ENCRYPTED_PROTOCOLS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: color.withOpacity(0.5), letterSpacing: 1, fontFamily: 'Courier'))),
        ],
      ),
    ));
  }

  Widget _buildCyberSocial(SignupController controller, Color color) {
    return Column(
      children: [
        Text('EXTERNAL_SOCIAL_LINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: color, letterSpacing: 2, fontFamily: 'Courier')),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => controller.signInWithGoogle(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              border: Border.all(color: color, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(TImageStrings.google, width: 20),
                const SizedBox(width: 16),
                Text('UPLINK_GOOGLE_V.1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color, letterSpacing: 1, fontFamily: 'Courier')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
