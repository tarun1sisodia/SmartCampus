import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutGlassmorphism extends StatelessWidget {
  const AboutGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          children: [
            _buildGlassHeader(),
            const SizedBox(height: 48),
            _buildGlassSection('SYSTEM_CORE', [
              const Text('The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14, height: 1.6)),
              const SizedBox(height: 24),
              _buildGlassIdentityChip(),
            ]),
            const SizedBox(height: 32),
            _buildGlassSection('DEVELOPER_UPLINK', [
              _buildDeveloperTile(name: 'Tarun Sisodia', role: 'Lead Architect', icon: Iconsax.code, color: Colors.blue[300]!),
              const SizedBox(height: 32),
              _buildSocialGrid(),
            ]),
            const SizedBox(height: 64),
            Center(child: Text('© 2025 SMART_CAMPUS_SYSTEM_CORE', style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36, letterSpacing: -1)),
        Text('CENTRAL_IDENTITY_UPLINK', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildGlassSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
        ),
        _glassContainer(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassIdentityChip() {
    return Row(
      children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24), image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover))),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Smart Campus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Version 0.0.1', style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildDeveloperTile({required String name, required String role, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(role, style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialGrid() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        _socialButton('G_DEV', 'https://g.dev/tarun1sisodia'),
        _socialButton('GITHUB', 'https://github.com/tarun1sisodia'),
        _socialButton('LINKEDIN', 'https://linkedin.com/in/tarun1sisodia'),
        _socialButton('X_CO', 'https://x.com/tarun1sisodia'),
      ],
    );
  }

  Widget _socialButton(String label, String url) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
      ),
    );
  }
}
