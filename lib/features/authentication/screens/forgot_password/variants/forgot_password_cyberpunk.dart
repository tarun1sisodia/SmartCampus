import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/forgot_password_controller.dart';

class ForgotPasswordCyberpunk extends StatelessWidget {
  const ForgotPasswordCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
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
                  _buildCyberHeader(cyan, magenta),
                  const SizedBox(height: 56),
                  _buildCyberForm(controller, cyan),
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
        painter: _GridPainter(color: color.withValues(alpha: 0.05)),
      ),
    );
  }

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: cyan, width: 2),
            boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 20)],
          ),
          child: Icon(Iconsax.password_check, color: cyan, size: 48),
        ),
        const SizedBox(height: 32),
        Text('RESET_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: cyan, letterSpacing: 4, fontFamily: 'Courier')),
        const SizedBox(height: 12),
        Text('INITIATING_SECURE_RECOVERY...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: magenta, letterSpacing: 2, fontFamily: 'Courier')),
        const SizedBox(height: 24),
        Text(
          'LOCATE_REGISTERED_IDENTITY_NODE_TO_RECEIVE_DECRYPTED_LINK.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: cyan.withValues(alpha: 0.4), height: 1.6, letterSpacing: 1, fontFamily: 'Courier'),
        ),
      ],
    );
  }

  Widget _buildCyberForm(ForgotPasswordController controller, Color color) {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: TextFormField(
              controller: controller.email,
              style: TextStyle(color: color, fontFamily: 'Courier'),
              validator: (value) => value!.isEmpty ? 'LOCATOR_MISSING' : null,
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right, color: color, size: 22),
                hintText: 'EMAIL ADDRESS',
                hintStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.3), letterSpacing: 2, fontFamily: 'Courier'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              ),
            ),
          ),
          const SizedBox(height: 56),
          GestureDetector(
            onTap: () => controller.sendPasswordResetEmail(),
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color, width: 2),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)],
              ),
              child: Center(child: Text('ESTABLISH_RECOVERY_NODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color, letterSpacing: 2, fontFamily: 'Courier'))),
            ),
          ),
        ],
      ),
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
