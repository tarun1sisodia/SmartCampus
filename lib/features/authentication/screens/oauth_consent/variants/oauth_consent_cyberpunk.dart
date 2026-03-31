import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../oauth_consent_controller.dart';

class OAuthConsentCyberpunk extends StatelessWidget {
  const OAuthConsentCyberpunk({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OAuthConsentController());
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                children: [
                  _buildCyberHeader(cyan, magenta),
                  const SizedBox(height: 56),
                  _buildCyberConsentCard(appName, scopes, cyan),
                  const SizedBox(height: 72),
                  _buildCyberActions(controller, cyan, magenta),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color color) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(color: color.withOpacity(0.05)),
      ),
    );
  }

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: cyan, width: 2),
            boxShadow: [BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Icon(Iconsax.security_user, color: cyan, size: 48),
        ),
        const SizedBox(height: 32),
        const Text('PERMISSION_REQUEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF00F5FF), letterSpacing: 4, fontFamily: 'Courier')),
        const SizedBox(height: 12),
        const Text('THIRD_PARTY_UPLINK_INITIATED...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFFF00CC), letterSpacing: 2, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildCyberConsentCard(String appName, List<String> scopes, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(appName.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: color, letterSpacing: 2, fontFamily: 'Courier')),
          const SizedBox(height: 32),
          const Text('REQUESTED_SCOPES:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFFF00CC), letterSpacing: 2, fontFamily: 'Courier')),
          const SizedBox(height: 24),
          ...scopes.map((scope) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: color, size: 18),
                const SizedBox(width: 12),
                Text(scope.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color.withOpacity(0.7), letterSpacing: 1, fontFamily: 'Courier')),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCyberActions(OAuthConsentController controller, Color cyan, Color magenta) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.grantConsent(),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: cyan.withOpacity(0.1),
              border: Border.all(color: cyan, width: 2),
              boxShadow: [BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 10)],
            ),
            child: const Center(child: Text('AUTHORIZE_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF00F5FF), letterSpacing: 2, fontFamily: 'Courier'))),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => controller.denyConsent(),
          child: const Text('ABORT_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFFF00CC), letterSpacing: 2, fontFamily: 'Courier')),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
