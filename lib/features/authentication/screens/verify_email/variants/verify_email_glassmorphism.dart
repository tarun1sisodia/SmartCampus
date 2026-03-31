import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/signup_controller.dart';

class VerifyEmailGlassmorphism extends StatelessWidget {
  const VerifyEmailGlassmorphism({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _glassContainer(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  _buildGlassHeader(),
                  const SizedBox(height: 56),
                  _buildGlassData(email),
                  const SizedBox(height: 48),
                  _buildGlassActions(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: const Icon(Iconsax.direct_send, color: Colors.white70, size: 48),
        ),
        const SizedBox(height: 24),
        const Text('Final Step', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 12),
        const Text('Ethereal Account Validation', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white54, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildGlassData(String? email) {
    return Column(
      children: [
        Text(email ?? 'Your Identity Node', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 24),
        Text(
          'We have transmitted an encrypted validation link. Access your inbox to secure your institutional profile.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white.withOpacity(0.4), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildGlassActions(SignupController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => controller.checkEmailVerificationStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.2))),
            ),
            child: const Text('Verify Uplink', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => controller.sendEmailVerification(),
          child: Text('Resend Transmission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white.withOpacity(0.4))),
        ),
      ],
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
