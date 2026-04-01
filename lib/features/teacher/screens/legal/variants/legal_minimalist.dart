import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalMinimalist extends StatefulWidget {
  final String initialSection;
  const LegalMinimalist({super.key, required this.initialSection});

  @override
  State<LegalMinimalist> createState() => _LegalMinimalistState();
}

class _LegalMinimalistState extends State<LegalMinimalist> {
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
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        children: [
          const Text('Legal', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: Colors.black87, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Transparency and Compliance.', style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5)),
          const SizedBox(height: 48),
          _buildMinimalSection(
            key: _sectionKeys['privacy_policy']!,
            title: 'Privacy Policy',
            icon: Iconsax.shield_tick,
            content: 'Last Updated: [05/05/2025]\n\nWe respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.\n\nInformation We Collect\n- Personal Information: User profiles, student details, authentication data, and usage data.\n- Technical Information: Device details, log data, and cookies.',
          ),
          const SizedBox(height: 48),
          _buildMinimalSection(
            key: _sectionKeys['terms_of_service']!,
            title: 'Terms of Service',
            icon: Iconsax.document_text,
            content: 'Last Updated: [05/05/2025]\n\nBy accessing or using SmartCampus, you agree to be bound by these Terms of Service.\n\nUser Accounts\n- Maintain confidentiality of your account credentials.\n- Notify us immediately of unauthorized use.\n\nUser Conduct\nYou agree not to:\n- Use the service for illegal purposes.',
          ),
          const SizedBox(height: 48),
          _buildMinimalSection(
            key: _sectionKeys['open_source_licenses']!,
            title: 'Open Source Licenses',
            icon: Iconsax.code,
            content: 'SmartCampus is built using various open-source software components. Acknowledgments include:\n\n- Flutter (BSD 3-Clause License)\n- Dart (BSD 3-Clause License)\n- GetX (MIT License)',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMinimalSection({required GlobalKey key, required String title, required IconData icon, required String content}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black.withValues(alpha: 0.2), size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black.withValues(alpha: 0.6))),
          ],
        ),
        const SizedBox(height: 16),
        Text(content, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black.withValues(alpha: 0.4), height: 1.8)),
      ],
    );
  }
}
