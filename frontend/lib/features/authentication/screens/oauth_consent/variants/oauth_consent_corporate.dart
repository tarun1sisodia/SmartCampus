import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/oauth_consent_controller.dart';

class OAuthConsentCorporate extends StatelessWidget {
  const OAuthConsentCorporate({
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
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              _buildCorporateHeader(),
              const SizedBox(height: 56),
              _buildCorporateConsentCard(appName, scopes),
              const SizedBox(height: 48),
              _buildCorporateActions(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorporateHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 3)),
          child: const Icon(Iconsax.security_user, color: Color(0xFF0F172A), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('AUTHORIZATION_REQUEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text('INITIATE_THIRD_PARTY_ACCESS_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildCorporateConsentCard(String appName, List<String> scopes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SOURCE_ENTITY:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: const Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(appName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
          const SizedBox(height: 32),
          const Text('REQUESTED_PERMISSIONS:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 16),
          ...scopes.map((scope) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(scope.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A), letterSpacing: 0.5))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCorporateActions(OAuthConsentController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => controller.grantConsent(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('AUTHORIZE_ACCESS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton(
            onPressed: () => controller.denyConsent(),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0F172A), width: 2), foregroundColor: const Color(0xFF0F172A), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('TERMINATE_REQUEST', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ),
      ],
    );
  }
}
