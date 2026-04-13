import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/oauth_consent_controller.dart';

class OAuthConsentAcademic extends StatelessWidget {
  const OAuthConsentAcademic({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);

    return Container(
      color: paperColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
          child: Column(
            children: [
              _buildScholarHeader(inkColor),
              const SizedBox(height: 72),
              _buildScholarConsentCard(appName, scopes, inkColor),
              const SizedBox(height: 48),
              _buildScholarActions(inkColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScholarHeader(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: color.withValues(alpha: 0.05)), shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Icon(Iconsax.security_user, color: color.withValues(alpha: 0.4), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF2D2E32), letterSpacing: 0, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        const Text('Institutional Authorization Protocol', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Color(0xFF2D2E32), letterSpacing: 0.5, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarConsentCard(String appName, List<String> scopes, Color color) {
    return Column(
      children: [
        Text(appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF2D2E32), fontFamily: 'Serif')),
        const SizedBox(height: 24),
        const Text('Requests access to the following institutional resources:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black38, fontFamily: 'Serif')),
        const SizedBox(height: 32),
        ...scopes.map((scope) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('• $scope', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFF2D2E32), fontFamily: 'Serif')),
        )),
      ],
    );
  }

  Widget _buildScholarActions(Color color) {
    final controller = Get.put(OAuthConsentController());

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => controller.grantConsent(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            child: const Text('Authorize Protocol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => controller.denyConsent(),
          child: Text('Deny & Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color.withValues(alpha: 0.5), fontFamily: 'Serif')),
        ),
      ],
    );
  }
}
