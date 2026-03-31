import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../oauth_consent_controller.dart';

class OAuthConsentNeumorphism extends StatelessWidget {
  const OAuthConsentNeumorphism({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildNeuHeader(bgColor),
              const SizedBox(height: 56),
              _buildNeuConsentCard(appName, scopes, bgColor),
              const SizedBox(height: 48),
              _buildNeuActions(bgColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeuHeader(Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(10, 10), blurRadius: 20),
            ],
          ),
          child: const Icon(Iconsax.security_user, color: Color(0xFFA3B1C6), size: 48),
        ),
        const SizedBox(height: 48),
        const Text('Gatekeeper', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF4D565F), letterSpacing: -1)),
        const SizedBox(height: 12),
        const Text('SECURE_TACTILE_CONSENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuConsentCard(String appName, List<String> scopes, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12, inset: true),
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12, inset: true),
        ],
      ),
      child: Column(
        children: [
          Text(appName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4D565F))),
          const SizedBox(height: 24),
          const Text('The application requests following scopes:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1)),
          const SizedBox(height: 24),
          ...scopes.map((scope) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFFA3B1C6), size: 16),
                const SizedBox(width: 12),
                Text(scope.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF4D565F), letterSpacing: 0.5)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNeuActions(Color bgColor) {
    final controller = Get.put(OAuthConsentController());

    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.grantConsent(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
              ],
            ),
            child: const Center(child: Text('AUTHORIZE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4D565F), letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => controller.denyConsent(),
          child: const Text('DENY_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFFA3B1C6), letterSpacing: 2)),
        ),
      ],
    );
  }
}
