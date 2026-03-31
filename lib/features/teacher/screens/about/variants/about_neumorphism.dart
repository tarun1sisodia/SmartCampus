import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutNeumorphism extends StatelessWidget {
  const AboutNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);
    
    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          _buildNeuHeader(),
          const SizedBox(height: 48),
          _buildNeuSection(bgColor, 'SYSTEM_IDENTITY', [
            const Center(child: Text('Smart Campus V1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Color(0xFF4D565F)))),
            const Center(child: Text('Version 0.0.1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6)))),
            const SizedBox(height: 32),
            _buildNeuAppLogo(bgColor),
            const SizedBox(height: 32),
            const Text('The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF4D565F), height: 1.6)),
          ]),
          const SizedBox(height: 32),
          _buildNeuSection(bgColor, 'DEVELOPER_UPLINK', [
            _buildNeuDeveloperTile(bgColor, name: 'Tarun Sisodia', role: 'Lead Architect', icon: Iconsax.code),
            const SizedBox(height: 32),
            _buildNeuSocialRow(bgColor),
          ]),
          const SizedBox(height: 64),
          const Center(child: Text('© 2025 SMART_CAMPUS_SYSTEM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNeuHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('About', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Color(0xFF4D565F), letterSpacing: -1)),
        Text('SYSTEM_IDENTITY_HUB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuSection(Color bg, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildNeuAppLogo(Color bg) {
    return Center(
      child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 12, inset: true),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 12, inset: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuDeveloperTile(Color bg, {required String name, required String role, required IconData icon}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.blue[400], size: 24)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4D565F))),
            Text(role, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFA3B1C6), letterSpacing: 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildNeuSocialRow(Color bg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _neuSocialButton(bg, Iconsax.global, 'https://g.dev/tarun1sisodia'),
        _neuSocialButton(bg, Iconsax.document_code, 'https://github.com/tarun1sisodia'),
        _neuSocialButton(bg, Iconsax.link, 'https://linkedin.com/in/tarun1sisodia'),
        _neuSocialButton(bg, Iconsax.message, 'https://x.com/tarun1sisodia'),
      ],
    );
  }

  Widget _neuSocialButton(Color bg, IconData icon, String url) {
    return GestureDetector(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(3, 3), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: Colors.blue[400], size: 18),
      ),
    );
  }
}
