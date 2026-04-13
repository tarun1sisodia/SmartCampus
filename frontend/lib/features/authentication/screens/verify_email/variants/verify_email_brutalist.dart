import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailBrutalist extends StatelessWidget {
  const VerifyEmailBrutalist({super.key, this.email});

  final String? email;

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
          child: const Icon(Iconsax.direct_send, color: Colors.black, size: 64),
        ),
        const SizedBox(height: 56),
        _stackText('VERIFY_ID', color, fontSize: 48),
        const SizedBox(height: 12),
        _brutalBadge('PENDING_ACCOUNT_VALIDATION_PROTOCOL'),
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

  Widget _buildBrutalData(String? email, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [BoxShadow(color: color, offset: const Offset(8, 8))],
      ),
      child: Column(
        children: [
          Text(email?.toUpperCase() ?? 'IDENTITY_PENDING', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 24),
          const Text(
            'INSTITUTIONAL VALIDATION LINK DISPATCHED. ACTIVATE YOUR IDENTITY VIA THE UPLINK IN YOUR INBOX.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black26, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalActions(Color color) {
    final controller = Get.put(SignupController());

    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.checkEmailVerificationStatus(),
          child: Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
            ),
            child: const Center(child: Text('VERIFY_ID_STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => controller.sendEmailVerification(),
          child: const Text('RE_DISPATCH_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black26, letterSpacing: 2)),
        ),
      ],
    );
  }
}
