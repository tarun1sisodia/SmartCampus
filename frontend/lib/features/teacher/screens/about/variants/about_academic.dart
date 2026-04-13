import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutAcademic extends StatelessWidget {
  const AboutAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513);

    return Container(
      color: paperColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        children: [
          _buildScholarHeader(accentColor, inkColor),
          const SizedBox(height: 48),
          _buildScholarIdentity(inkColor, paperColor),
          const SizedBox(height: 48),
          _buildScholarSection('SYSTEM_SPECIFICATION', [
            const Text('The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black45, height: 1.6, fontFamily: 'Serif')),
          ], inkColor),
          const SizedBox(height: 32),
          _buildScholarSection('FACULTY_LEADERSHIP', [
            _buildDeveloperTile(name: 'Tarun Sisodia', role: 'Lead Architect', icon: Iconsax.code, color: inkColor),
            const SizedBox(height: 32),
            _buildScholarSocialRow(inkColor),
          ], inkColor),
          const SizedBox(height: 64),
          Center(child: Text('© 2025 SmartCampus • Institutional Records', style: TextStyle(color: inkColor.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, fontFamily: 'Serif'))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScholarHeader(Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 36, fontFamily: 'Serif')),
        Text('CENTRAL_IDENTITY_LEDGER_V1', style: TextStyle(color: accent.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarIdentity(Color ink, Color paper) {
    return Center(
      child: Column(
        children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withValues(alpha: 0.1)), shape: BoxShape.circle, image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover))),
          const SizedBox(height: 24),
          const Text('Smart Campus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5, fontFamily: 'Serif')),
          Text('Institutional Build v0.0.1', style: TextStyle(color: ink.withValues(alpha: 0.4), fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif')),
        ],
      ),
    );
  }

  Widget _buildScholarSection(String title, List<Widget> items, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif')),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: ink.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildDeveloperTile({required String name, required String role, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFAF7F0), border: Border.all(color: Colors.black.withValues(alpha: 0.05))), child: Icon(icon, color: color.withValues(alpha: 0.6), size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
            Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, color: Colors.black26, fontFamily: 'Serif')),
          ],
        ),
      ],
    );
  }

  Widget _buildScholarSocialRow(Color ink) {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        _socialRecord('G_DEV', 'https://g.dev/tarun1sisodia'),
        _socialRecord('GITHUB', 'https://github.com/tarun1sisodia'),
        _socialRecord('LINKEDIN', 'https://linkedin.com/in/tarun1sisodia'),
        _socialRecord('X_CO', 'https://x.com/tarun1sisodia'),
      ],
    );
  }

  Widget _socialRecord(String label, String url) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black38, letterSpacing: 1, fontFamily: 'Serif')),
      ),
    );
  }
}
