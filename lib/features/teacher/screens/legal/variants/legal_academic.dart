import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalAcademic extends StatefulWidget {
  final String initialSection;
  const LegalAcademic({super.key, required this.initialSection});

  @override
  State<LegalAcademic> createState() => _LegalAcademicState();
}

class _LegalAcademicState extends State<LegalAcademic> {
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
          _buildScholarSection(
            key: _sectionKeys['privacy_policy']!,
            title: 'I. Privacy Policy',
            icon: Iconsax.shield_tick,
            content: 'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.',
            inkColor: inkColor,
          ),
          const SizedBox(height: 32),
          _buildScholarSection(
            key: _sectionKeys['terms_of_service']!,
            title: 'II. Terms of Service',
            icon: Iconsax.document_text,
            content: 'By accessing or using SmartCampus, you agree to be bound by these Terms of Service.',
            inkColor: inkColor,
          ),
          const SizedBox(height: 32),
          _buildScholarSection(
            key: _sectionKeys['open_source_licenses']!,
            title: 'III. Open Source Licenses',
            icon: Iconsax.code,
            content: 'SmartCampus is built using various open-source software components.',
            inkColor: inkColor,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScholarHeader(Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legal', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 36, fontFamily: 'Serif')),
        Text('REGULATORY_RECORDS_PROTOCOL', style: TextStyle(color: accent.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarSection({required GlobalKey key, required String title, required IconData icon, required String content, required Color inkColor}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black26, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5, fontFamily: 'Serif')),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: inkColor.withOpacity(0.05)), boxShadow: [BoxShadow(color: inkColor.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black45, height: 1.6, fontFamily: 'Serif')),
        ),
      ],
    );
  }
}
