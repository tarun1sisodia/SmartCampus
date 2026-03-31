import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../oauth_consent_controller.dart';

class OAuthConsentMinimalist extends StatelessWidget {
  const OAuthConsentMinimalist({
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
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              _buildMinimalHeader(),
              const SizedBox(height: 56),
              _buildMinimalConsentCard(appName, scopes),
              const SizedBox(height: 72),
              _buildMinimalActions(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Column(
      children: [
        const Icon(Iconsax.security_user, color: Colors.black12, size: 64),
        const SizedBox(height: 32),
        const Text('Authorization', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.black87, letterSpacing: -1.5)),
        const SizedBox(height: 12),
        const Text('Third-party application access request.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildMinimalConsentCard(String appName, List<String> scopes) {
    return Column(
      children: [
        Text(appName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.black87)),
        const SizedBox(height: 32),
        const Text('The following permissions are requested:', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black26)),
        const SizedBox(height: 24),
        ...scopes.map((scope) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check, color: Colors.black12, size: 16),
              const SizedBox(width: 12),
              Text(scope, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.black54)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMinimalActions(OAuthConsentController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => controller.grantConsent(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Allow Access', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => controller.denyConsent(),
          child: const Text('Deny & Close', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black26)),
        ),
      ],
    );
  }
}
