import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/oauth_consent_controller.dart';

class OAuthConsentCupertino extends StatelessWidget {
  const OAuthConsentCupertino({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OAuthConsentController());

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildIosHeader(),
              const SizedBox(height: 56),
              _buildIosConsentCard(appName, scopes),
              const SizedBox(height: 72),
              _buildIosActions(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 10))]),
          child: const Icon(Iconsax.security_user, color: Color(0xFF007AFF), size: 48),
        ),
        const SizedBox(height: 32),
        const Text('Authorization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1, color: Color(0xFF000000))),
        const SizedBox(height: 8),
        const Text('Third-Party Access Request Protocol', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildIosConsentCard(String appName, List<String> scopes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          Text(appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF000000))),
          const SizedBox(height: 32),
          const Text('The application requests access to:', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
          const SizedBox(height: 24),
          ...scopes.map((scope) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF34C759), size: 18),
                const SizedBox(width: 12),
                Text(scope, style: const TextStyle(fontSize: 15, color: Color(0xFF000000))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildIosActions(OAuthConsentController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CupertinoButton.filled(
            borderRadius: BorderRadius.circular(14),
            onPressed: () => controller.grantConsent(),
            child: const Text('Allow Access', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CupertinoButton(
            onPressed: () => controller.denyConsent(),
            child: const Text('Deny Access', style: TextStyle(fontSize: 17, color: Color(0xFFFF3B30))),
          ),
        ),
      ],
    );
  }
}
