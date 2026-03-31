import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutMinimalist extends StatelessWidget {
  const AboutMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        children: [
          const Text('About', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: Colors.black87, letterSpacing: -0.5)),
          const SizedBox(height: 48),
          Center(
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[100]!, width: 1), image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 32),
          const Center(child: Text('Smart Campus', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black87))),
          const Center(child: Text('Version 0.0.1', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black26))),
          const SizedBox(height: 48),
          _buildMinimalSection('Mission', 'The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.'),
          const SizedBox(height: 48),
          _buildDeveloperSection(),
          const SizedBox(height: 64),
          _buildSocialRow(),
          const SizedBox(height: 32),
          Center(child: Text('© 2025 SmartCampus', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMinimalSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black.withOpacity(0.6))),
        const SizedBox(height: 16),
        Text(content, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black.withOpacity(0.4), height: 1.6)),
      ],
    );
  }

  Widget _buildDeveloperSection() {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50]!, shape: BoxShape.circle), child: const Icon(Iconsax.code, color: Colors.black54, size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tarun Sisodia', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
            Text('Lead Architect', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black.withOpacity(0.3))),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(Iconsax.global, 'https://g.dev/tarun1sisodia'),
        const SizedBox(width: 24),
        _socialIcon(Iconsax.document_code, 'https://github.com/tarun1sisodia'),
        const SizedBox(width: 24),
        _socialIcon(Iconsax.link, 'https://linkedin.com/in/tarun1sisodia'),
        const SizedBox(width: 24),
        _socialIcon(Iconsax.message, 'https://x.com/tarun1sisodia'),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Icon(icon, color: Colors.black.withOpacity(0.2), size: 20),
    );
  }
}
