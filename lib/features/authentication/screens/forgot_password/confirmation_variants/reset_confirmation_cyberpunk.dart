import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/forgot_password_controller.dart';

class ResetConfirmationCyberpunk extends StatelessWidget {
  const ResetConfirmationCyberpunk({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 48),
                  _buildCyberActions(cyan, magenta),
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
          child: Icon(Icons.mark_email_read_outlined, color: cyan, size: 48),
        ),
        const SizedBox(height: 32),
        Text('UPLINK_SUCCESS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: cyan, letterSpacing: 4, fontFamily: 'Courier')),
        const SizedBox(height: 12),
        Text('ENCRYPTED_COMMUNICATION_DISPATCHED.', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: magenta, letterSpacing: 2, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildCyberData(String email, Color cyan) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan.withValues(alpha: 0.3))),
      child: Column(
        children: [
          Text('RECIPIENT_NODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: cyan.withValues(alpha: 0.4), letterSpacing: 2, fontFamily: 'Courier')),
          const SizedBox(height: 12),
          Text(email.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: cyan, letterSpacing: 1, fontFamily: 'Courier')),
          const SizedBox(height: 24),
          Text(
            'LOCATE_THE_DECRYPTED_LINK_IN_YOUR_INBOX_TO_RE_RE_INITIALIZE_IDENTITY_CREDENTIALS.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: cyan.withValues(alpha: 0.4), height: 1.6, letterSpacing: 1, fontFamily: 'Courier'),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberActions(Color cyan, Color magenta) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: cyan.withValues(alpha: 0.1),
              border: Border.all(color: cyan, width: 2),
              boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 10)],
            ),
            child: Center(child: Text('TERMINATE_SESSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: cyan, letterSpacing: 2, fontFamily: 'Courier'))),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: Text('RE_DISPATCH_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: magenta, letterSpacing: 1, fontFamily: 'Courier')),
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
