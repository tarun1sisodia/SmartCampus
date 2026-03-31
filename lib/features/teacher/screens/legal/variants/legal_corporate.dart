import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalCorporate extends StatefulWidget {
  final String initialSection;
  const LegalCorporate({super.key, required this.initialSection});

  @override
  State<LegalCorporate> createState() => _LegalCorporateState();
}

class _LegalCorporateState extends State<LegalCorporate> {
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
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          const Text('LEGAL_COMPLIANCE_REGISTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
          const SizedBox(height: 32),
          _buildCorporateSection(
            key: _sectionKeys['privacy_policy']!,
            title: 'PRIVACY_POLICY_STMT',
            icon: Iconsax.shield_tick,
            content: 'Last Updated: [05/05/2025]\n\nWe respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.\n\nInformation We Collect\n- Personal Information: User profiles, student details, authentication data, and usage data.\n- Technical Information: Device details, log data, and cookies.\n\nHow We Use Your Information\n- To provide and maintain our service.\n- To authenticate users and manage access permissions.\n- To track and manage attendance records.',
          ),
          const SizedBox(height: 32),
          _buildCorporateSection(
            key: _sectionKeys['terms_of_service']!,
            title: 'TERMS_OF_SERVICE_STMT',
            icon: Iconsax.document_text,
            content: 'Last Updated: [05/05/2025]\n\nBy accessing or using SmartCampus, you agree to be bound by these Terms of Service.\n\nUser Accounts\n- Maintain confidentiality of your account credentials.\n- Notify us immediately of unauthorized use.\n\nUser Conduct\nYou agree not to:\n- Use the service for illegal purposes.\n- Violate laws or regulations.\n- Interfere with or disrupt the service.',
          ),
          const SizedBox(height: 32),
          _buildCorporateSection(
            key: _sectionKeys['open_source_licenses']!,
            title: 'OPEN_SOURCE_LICENSES_STMT',
            icon: Iconsax.code,
            content: 'SmartCampus is built using various open-source software components. Acknowledgments include:\n\n- Flutter (BSD 3-Clause License)\n- Dart (BSD 3-Clause License)\n- GetX (MIT License)\n- Supabase (Apache License 2.0)\n- Cached Network Image (MIT License)',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCorporateSection({required GlobalKey key, required String title, required IconData icon, required String content}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.1), border: Border.all(color: const Color(0xFF0F172A).withOpacity(0.2))), child: Icon(icon, color: const Color(0xFF0F172A), size: 18)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A), letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
          child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569), height: 1.6)),
        ),
      ],
    );
  }
}
