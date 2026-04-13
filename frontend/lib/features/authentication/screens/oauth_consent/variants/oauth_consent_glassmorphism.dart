import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/oauth_consent_controller.dart';

class OAuthConsentGlassmorphism extends StatelessWidget {
  const OAuthConsentGlassmorphism({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OAuthConsentController());

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
                  _buildGlassConsentCard(appName, scopes),
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
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
          child: const Icon(Iconsax.security_user, color: Colors.white70, size: 48),
        ),
        const SizedBox(height: 24),
        const Text('Authorization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 12),
        const Text('Ethereal Access Protocol', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white54, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildGlassConsentCard(String appName, List<String> scopes) {
    return Column(
      children: [
        Text(appName.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        const SizedBox(height: 32),
        Text('The application requests following scopes:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white.withValues(alpha: 0.4))),
        const SizedBox(height: 24),
        ...scopes.map((scope) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white30, size: 18),
              const SizedBox(width: 12),
              Text(scope, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white70)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildGlassActions(OAuthConsentController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => controller.grantConsent(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
            ),
            child: const Text('Authorize Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => controller.denyConsent(),
          child: Text('Deny Protocol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white.withValues(alpha: 0.4))),
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
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
