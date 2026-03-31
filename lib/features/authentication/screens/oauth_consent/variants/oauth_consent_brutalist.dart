import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../oauth_consent_controller.dart';

class OAuthConsentBrutalist extends StatelessWidget {
  const OAuthConsentBrutalist({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

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
              _buildBrutalHeader(orange),
              const SizedBox(height: 72),
              _buildBrutalConsentCard(appName, scopes, yellow),
              const SizedBox(height: 48),
              _buildBrutalActions(blue),
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
          child: const Icon(Iconsax.security_user, color: Colors.black, size: 64),
        ),
        const SizedBox(height: 56),
        _stackText('AUTHORIZE_APP', color, fontSize: 48),
        const SizedBox(height: 12),
        _brutalBadge('ACCESS_REQUEST_VERIFICATION_PENDING'),
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

  Widget _buildBrutalConsentCard(String appName, List<String> scopes, Color color) {
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
          Text(appName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 32),
          const Text('PERMISSIONS_LIST:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black26)),
          const SizedBox(height: 24),
          ...scopes.map((scope) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_box_outlined, color: Colors.black, size: 20),
                const SizedBox(width: 12),
                Text(scope.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBrutalActions(Color color) {
    final controller = Get.put(OAuthConsentController());

    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.grantConsent(),
          child: Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
            ),
            child: const Center(child: Text('APPROVE_REQUEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => controller.denyConsent(),
          child: const Text('ABORT_AUTHORIZATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black26, letterSpacing: 2)),
        ),
      ],
    );
  }
}
