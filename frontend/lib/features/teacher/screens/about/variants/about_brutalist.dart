import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutBrutalist extends StatelessWidget {
  const AboutBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildBrutalHeader(yellow),
          const SizedBox(height: 48),
          _buildBrutalIdentity(yellow, orange),
          const SizedBox(height: 32),
          _buildBrutalSection('APPLICATION_MANIFEST', [
            const Text('THE SMART CAMPUS ATTENDANCE MANAGEMENT SYSTEM IS A CROSS-PLATFORM INSTITUTIONAL UTILITY DESIGNED TO OPTIMIZE ACADEMIC REGISTRIES AND STREAMLINE STUDENT TRACKING PROTOCOLS VIA ADVANCED FLUTTER ARCHITECTURE.', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, height: 1.5, color: Colors.black)),
          ], blue),
          const SizedBox(height: 32),
          _buildBrutalSection('DEVELOPER_STATUS', [
            _buildDeveloperTile(name: 'TARUN SISODIA', role: 'LEAD_ARCHITECT', icon: Iconsax.code, color: yellow),
            const SizedBox(height: 32),
            _buildSocialUplinks(blue, orange),
          ], orange),
          const SizedBox(height: 64),
          const Center(child: Text('© 2025 SMART_CAMPUS • ALL_CHANNELS_OPEN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBrutalHeader(Color yellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black,
          child: const Text('IDENTITY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: yellow,
          child: const Text('CENTRAL_SYSTEM_REGISTRY_V1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildBrutalIdentity(Color yellow, Color orange) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 4), boxShadow: [BoxShadow(color: yellow, offset: const Offset(12, 12))]),
        child: Column(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 3), image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover))),
            const SizedBox(height: 24),
            const Text('SMART_CAMPUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), color: orange, child: const Text('BUILD_v0.0.1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
          ],
        ),
      ),
    );
  }

  Widget _buildBrutalSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildDeveloperTile({required String name, required String role, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black, width: 2), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]), child: Icon(icon, color: Colors.black, size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text(role, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.black45)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialUplinks(Color blue, Color orange) {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        _socialChip('G_DEV', 'https://g.dev/tarun1sisodia', blue),
        _socialChip('GITHUB', 'https://github.com/tarun1sisodia', orange),
        _socialChip('LINKEDIN', 'https://linkedin.com/in/tarun1sisodia', blue),
        _socialChip('X_CO', 'https://x.com/tarun1sisodia', orange),
      ],
    );
  }

  Widget _socialChip(String label, String url, Color accent) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), boxShadow: [BoxShadow(color: accent, offset: const Offset(4, 4))]),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
      ),
    );
  }
}
