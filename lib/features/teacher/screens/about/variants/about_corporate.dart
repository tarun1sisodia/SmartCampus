import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutCorporate extends StatelessWidget {
  const AboutCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          const Text('SYSTEM_IDENTITY_REGISTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 3), shape: BoxShape.circle, image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 24),
          const Center(child: Text('SMART_CAMPUS_V1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: -0.5))),
          const Center(child: Text('BUILD_STABLE_0.0.1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF94A3B8), letterSpacing: 1))),
          const SizedBox(height: 48),
          _buildCorporateSection('CORE_SPECIFICATIONS', [
            const Text('The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569), height: 1.6)),
          ]),
          const SizedBox(height: 24),
          _buildCorporateSection('DEVELOPER_UPLINK', [
            _buildDeveloperTile(name: 'TARUN SISODIA', role: 'LEAD_SYSTEM_ARCHITECT', icon: Iconsax.code, color: const Color(0xFF0F172A)),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF1F5F9)),
            _buildSocialGrid(),
          ]),
          const SizedBox(height: 48),
          const Center(child: Text('© 2025 SMART_CAMPUS • ALL_RIGHTS_RESERVED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8), letterSpacing: 1.5))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCorporateSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 2)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _buildDeveloperTile({required String name, required String role, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.2))), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B))),
            Text(role, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8), letterSpacing: 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialGrid() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        _buildSocialChip('G_DEV', 'https://g.dev/tarun1sisodia'),
        _buildSocialChip('GITHUB', 'https://github.com/tarun1sisodia'),
        _buildSocialChip('LINKEDIN', 'https://linkedin.com/in/tarun1sisodia'),
        _buildSocialChip('X_CO', 'https://x.com/tarun1sisodia'),
      ],
    );
  }

  Widget _buildSocialChip(String label, String url) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
      ),
    );
  }
}
