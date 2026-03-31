import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailCyberpunk extends StatelessWidget {
  const VerifyEmailCyberpunk({super.key, this.email});

  final String? email;

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
                  _buildCyberHeader(cyan, magenta),
                  const SizedBox(height: 56),
                  _buildCyberData(email, cyan),
                  const SizedBox(height: 72),
                  _buildCyberActions(controller, cyan, magenta),
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

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: cyan, width: 2),
            boxShadow: [BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Icon(Iconsax.direct_send, color: cyan, size: 48),
        ),
        const SizedBox(height: 32),
        const Text('IDENTITY_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF00F5FF), letterSpacing: 4, fontFamily: 'Courier')),
        const SizedBox(height: 12),
        const Text('INITIATING_ACCOUNT_VALIDATION_SEQUENCE...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFFF02CC), letterSpacing: 2, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildCyberData(String? email, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(email?.toUpperCase() ?? 'NODE_ID_PENDING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color, letterSpacing: 2, fontFamily: 'Courier')),
          const SizedBox(height: 24),
          Text(
            'Institutional validation link transmitted. Access your terminal to secure your profile access.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color.withOpacity(0.4), height: 1.6, letterSpacing: 1, fontFamily: 'Courier'),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberActions(SignupController controller, Color cyan, Color magenta) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.checkEmailVerificationStatus(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: cyan.withOpacity(0.1),
              border: Border.all(color: cyan, width: 2),
              boxShadow: [BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 10)],
            ),
            child: const Center(child: Text('VERIFY_STATUS_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF00F5FF), letterSpacing: 2, fontFamily: 'Courier'))),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => controller.sendEmailVerification(),
          child: const Text('RE_DISPATCH_TRANSMISSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFFF00CC), letterSpacing: 2, fontFamily: 'Courier')),
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
