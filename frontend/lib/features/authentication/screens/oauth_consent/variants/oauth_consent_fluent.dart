import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/oauth_consent_controller.dart';

class OAuthConsentFluent extends StatelessWidget {
  const OAuthConsentFluent({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    const accentColor = Color(0xFF0078D4);

    return Container(
      color: fluentBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
          child: Column(
            children: [
              _buildFluentHeader(accentColor),
              const SizedBox(height: 56),
              _buildFluentConsentCard(appName, scopes, accentColor),
              const SizedBox(height: 48),
              _buildFluentActions(accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFluentHeader(Color color) {
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
        const Text('Unified Authorization Success', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF605E5C), letterSpacing: 0)),
      ],
    );
  }

  Widget _buildFluentConsentCard(String appName, List<String> scopes, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF201F1E))),
          const SizedBox(height: 32),
          Text('Requests following permissions:', style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.4))),
          const SizedBox(height: 24),
          ...scopes.map((scope) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: color, size: 18),
                const SizedBox(width: 12),
                Text(scope, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFF201F1E))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFluentActions(Color color) {
    final controller = Get.put(OAuthConsentController());

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => controller.grantConsent(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Allow Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => controller.denyConsent(),
          child: Text('Deny & Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color.withValues(alpha: 0.5))),
        ),
      ],
    );
  }
}
