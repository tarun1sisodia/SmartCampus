import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers_forgot_password/forgot_password_controller.dart';

class ResetConfirmationBrutalist extends StatelessWidget {
  const ResetConfirmationBrutalist({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
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
              _buildBrutalHeader(blue),
              const SizedBox(height: 72),
              _buildBrutalData(email, yellow),
              const SizedBox(height: 48),
              _buildBrutalActions(orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalHeader(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [BoxShadow(color: color, offset: const Offset(12, 12))],
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: Colors.black, size: 64),
        ),
        const SizedBox(height: 56),
        _stackText('UPLINK_SENT', color, fontSize: 48),
        const SizedBox(height: 12),
        _brutalBadge('COMMUNICATION_VERIFIED'),
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

  Widget _buildBrutalData(String email, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [BoxShadow(color: color, offset: const Offset(8, 8))],
      ),
      child: Column(
        children: [
          Text(email.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 24),
          const Text(
            'ENCRYPTED_LINK_TRANSMITTED. CHECK_INBOX_IMMEDIATELY_TO_RE_RE_ESTABLISH_ACCESS.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalActions(Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
            ),
            child: const Center(child: Text('TERMINATE_REQUEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => ForgotPasswordController.instance.resendPasswordResetEmail(email),
          child: const Text('RE_DISPATCH_LINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black26, letterSpacing: 2)),
        ),
      ],
    );
  }
}
