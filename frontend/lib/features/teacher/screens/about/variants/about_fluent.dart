import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutFluent extends StatelessWidget {
  const AboutFluent({super.key});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    
    return Container(
      color: fluentBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          _buildFluentHeader(),
          const SizedBox(height: 32),
          _buildFluentIdentity(fluentBg),
          const SizedBox(height: 32),
          _buildFluentSection('SYSTEM_MANIFEST', [
            const Text('The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.', style: TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.w500, fontSize: 13, height: 1.5)),
          ]),
          const SizedBox(height: 24),
          _buildFluentSection('DEVELOPER_UPLINK', [
            _buildDeveloperRow(name: 'Tarun Sisodia', role: 'Lead Architect', icon: Iconsax.code, color: const Color(0xFF0078D4)),
            const SizedBox(height: 32),
            _buildSocialUplinks(),
          ]),
          const SizedBox(height: 64),
          Center(child: Text('© 2025 SmartCampus • Institutional Build', style: TextStyle(color: Colors.black.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFluentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('About', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        Text('CENTRAL_IDENTITY_PROTOCOL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0078D4), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildFluentIdentity(Color bg) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 1), image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover))),
          const SizedBox(height: 24),
          const Text('Smart Campus', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF201F1E))),
          const Text('Version 0.0.1 Stable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFA19F9D), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildFluentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildDeveloperRow({required String name, required String role, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: color.withValues(alpha: 0.6), size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF201F1E))),
            Text(role, style: const TextStyle(color: Color(0xFFA19F9D), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialUplinks() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: [
        _fluentSocialChip('G_DEV', 'https://g.dev/tarun1sisodia'),
        _fluentSocialChip('GITHUB', 'https://github.com/tarun1sisodia'),
        _fluentSocialChip('LINKEDIN', 'https://linkedin.com/in/tarun1sisodia'),
        _fluentSocialChip('X_CO', 'https://x.com/tarun1sisodia'),
      ],
    );
  }

  Widget _fluentSocialChip(String label, String url) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF605E5C), letterSpacing: 0.5)),
      ),
    );
  }
}
