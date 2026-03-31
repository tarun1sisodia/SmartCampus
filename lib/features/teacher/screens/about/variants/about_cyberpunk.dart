import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutCyberpunk extends StatelessWidget {
  const AboutCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            children: [
              _buildCyberHeader(cyan, magenta),
              const SizedBox(height: 48),
              _buildCyberIdentity(cyan, magenta),
              const SizedBox(height: 32),
              _buildCyberSection('SYSTEM_MANIFEST_X01', [
                const Text('THE SMART CAMPUS ATTENDANCE MANAGEMENT SYSTEM IS A CROSS-PLATFORM INSTITUTIONAL UTILITY DESIGNED TO OPTIMIZE ACADEMIC REGISTRIES AND STREAMLINE STUDENT TRACKING PROTOCOLS VIA ADVANCED FLUTTER ARCHITECTURE.', style: TextStyle(color: Color(0xFF00F5FF), fontWeight: FontWeight.bold, fontSize: 12, height: 1.5, fontFamily: 'Courier')),
              ], cyan),
              const SizedBox(height: 32),
              _buildCyberSection('DEVELOPER_UPLINK_X01', [
                _buildDeveloperTile(name: 'TARUN SISODIA', role: 'LEAD_SYSTEM_ARCHITECT', icon: Iconsax.code, color: magenta),
                const SizedBox(height: 32),
                _buildSocialUplinks(cyan, magenta),
              ], magenta),
              const SizedBox(height: 64),
              const Center(child: Text('© 2025 SMART_CAMPUS • CORE_STABLE_V1', style: TextStyle(color: Color(0xFFFF00CC), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, fontFamily: 'Courier'))),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withOpacity(0.04))));
  }

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('IDENTITY', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2, fontFamily: 'Courier')),
        Text('CORE_SYSTEM_REGISTRY', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: cyan),
      ],
    );
  }

  Widget _buildCyberIdentity(Color cyan, Color magenta) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan, width: 2), boxShadow: [BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 20)]),
        child: Column(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: magenta, width: 2), image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover))),
            const SizedBox(height: 16),
            const Text('SMART_CAMPUS_V1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1, fontFamily: 'Courier')),
            Text('BUILD_STABLE_0.0.1', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, fontFamily: 'Courier')),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: accent.withOpacity(0.3), width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildDeveloperTile({required String name, required String role, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: color)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Courier')),
            Text(role, style: TextStyle(color: color.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, fontFamily: 'Courier')),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialUplinks(Color cyan, Color magenta) {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        _cyberSocialChip('G_DEV', 'https://g.dev/tarun1sisodia', cyan),
        _cyberSocialChip('GITHUB', 'https://github.com/tarun1sisodia', magenta),
        _cyberSocialChip('LINKEDIN', 'https://linkedin.com/in/tarun1sisodia', cyan),
        _cyberSocialChip('X_CO', 'https://x.com/tarun1sisodia', magenta),
      ],
    );
  }

  Widget _cyberSocialChip(String label, String url, Color color) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.3))),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, fontFamily: 'Courier')),
      ),
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
