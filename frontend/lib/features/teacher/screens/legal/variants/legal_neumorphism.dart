import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:iconsax/iconsax.dart';

class LegalNeumorphism extends StatefulWidget {
  final String initialSection;
  const LegalNeumorphism({super.key, required this.initialSection});

  @override
  State<LegalNeumorphism> createState() => _LegalNeumorphismState();
}

class _LegalNeumorphismState extends State<LegalNeumorphism> {
  final Map<String, GlobalKey> _sectionKeys = {
    'privacy_policy': GlobalKey(),
    'terms_of_service': GlobalKey(),
    'open_source_licenses': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSection(widget.initialSection);
    });
  }

  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

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
          _buildNeuSection(
            key: _sectionKeys['privacy_policy']!,
            title: 'Privacy Policy',
            icon: Iconsax.shield_tick,
            content: 'Last Updated: [05/05/2025]\n\nWe respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.\n\nInformation We Collect\n- Personal Information: User profiles, student details, authentication data, and usage data.',
            bgColor: bgColor,
          ),
          const SizedBox(height: 32),
          _buildNeuSection(
            key: _sectionKeys['terms_of_service']!,
            title: 'Terms of Service',
            icon: Iconsax.document_text,
            content: 'Last Updated: [05/05/2025]\n\nBy accessing or using SmartCampus, you agree to be bound by these Terms of Service.',
            bgColor: bgColor,
          ),
          const SizedBox(height: 32),
          _buildNeuSection(
            key: _sectionKeys['open_source_licenses']!,
            title: 'Open Source Licenses',
            icon: Iconsax.code,
            content: 'SmartCampus is built using various open-source software components. Acknowledgments include:\n\n- Flutter (BSD 3-Clause License)\n- Dart (BSD 3-Clause License)\n- GetX (MIT License)',
            bgColor: bgColor,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNeuHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Legal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Color(0xFF4D565F), letterSpacing: -1)),
        Text('COMPLIANCE_UPLINK_STATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuSection({required GlobalKey key, required String title, required IconData icon, required String content, required Color bgColor}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFA3B1C6), size: 18),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
            ],
          ),
          child: Text(content, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF4D565F), height: 1.6)),
        ),
      ],
    );
  }
}
