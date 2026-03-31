import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalFluent extends StatefulWidget {
  final String initialSection;
  const LegalFluent({super.key, required this.initialSection});

  @override
  State<LegalFluent> createState() => _LegalFluentState();
}

class _LegalFluentState extends State<LegalFluent> {
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
    const fluentBg = Color(0xFFF3F3F3);
    
    return Container(
      color: fluentBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          _buildFluentHeader(),
          const SizedBox(height: 32),
          _buildFluentSection(
            key: _sectionKeys['privacy_policy']!,
            title: 'PRIVACY_POLICY',
            icon: Iconsax.shield_tick,
            content: 'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.',
          ),
          const SizedBox(height: 24),
          _buildFluentSection(
            key: _sectionKeys['terms_of_service']!,
            title: 'TERMS_OF_SERVICE',
            icon: Iconsax.document_text,
            content: 'By accessing or using SmartCampus, you agree to be bound by these Terms of Service.',
          ),
          const SizedBox(height: 24),
          _buildFluentSection(
            key: _sectionKeys['open_source_licenses']!,
            title: 'OPEN_SOURCE_MODULES',
            icon: Iconsax.code,
            content: 'SmartCampus is built using various open-source software components.',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFluentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Legal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        Text('COMPLIANCE_UPLINK_PROTOCOL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0078D4), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildFluentSection({required GlobalKey key, required String title, required IconData icon, required String content}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0078D4), size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Text(content, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.w500, fontSize: 13, height: 1.5)),
        ),
      ],
    );
  }
}
