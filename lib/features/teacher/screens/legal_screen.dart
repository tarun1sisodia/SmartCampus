// filepath: /home/charon/Studio/smartcampusapp/SmartCampus/lib/features/teacher/screens/legal_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalScreen extends StatefulWidget {
  final String initialSection;

  const LegalScreen({super.key, required this.initialSection});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  final ScrollController _scrollController = ScrollController();

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
    if (key != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Information'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Policy Section
            _buildSectionHeader(
              key: _sectionKeys['privacy_policy']!,
              title: 'Privacy Policy',
              icon: Iconsax.shield_tick,
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: [05/05/2025]\n\n'
              'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.\n\n'
              'Information We Collect\n'
              '- Personal Information: User profiles, student details, authentication data, and usage data.\n'
              '- Technical Information: Device details, log data, and cookies.\n\n'
              'How We Use Your Information\n'
              '- To provide and maintain our service.\n'
              '- To authenticate users and manage access permissions.\n'
              '- To track and manage attendance records.\n'
              '- To generate reports and analytics.\n'
              '- To improve our application and user experience.\n\n'
              'Data Storage and Security\n'
              '- Data is securely stored using Supabase\'s infrastructure.\n'
              '- Personal data is retained only as long as necessary.\n\n'
              'Data Sharing\n'
              '- We do not sell or rent personal information.\n'
              '- Data may be shared with educational institutions, service providers, or legal authorities when required.\n\n'
              'Your Rights\n'
              '- Access, correct, or delete your personal data.\n'
              '- Object to or restrict certain processing activities.',
            ),
            const SizedBox(height: 24),

            // Terms of Service Section
            _buildSectionHeader(
              key: _sectionKeys['terms_of_service']!,
              title: 'Terms of Service',
              icon: Iconsax.document_text,
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: [05/05/2025]\n\n'
              'Acceptance of Terms\n'
              'By accessing or using SmartCampus, you agree to be bound by these Terms of Service.\n\n'
              'User Accounts\n'
              '- Maintain confidentiality of your account credentials.\n'
              '- Notify us immediately of unauthorized use.\n\n'
              'User Conduct\n'
              'You agree not to:\n'
              '- Use the service for illegal purposes.\n'
              '- Violate laws or regulations.\n'
              '- Interfere with or disrupt the service.\n\n'
              'Intellectual Property\n'
              'The application and its content are owned by SmartCampus and protected by intellectual property laws.\n\n'
              'Termination\n'
              'We may terminate or suspend your account for violating these terms.',
            ),
            const SizedBox(height: 24),

            // Open Source Licenses Section
            _buildSectionHeader(
              key: _sectionKeys['open_source_licenses']!,
              title: 'Open Source Licenses',
              icon: Iconsax.code,
            ),
            const SizedBox(height: 8),
            const Text(
              'SmartCampus is built using various open-source software components. Acknowledgments include:\n\n'
              '- Flutter (BSD 3-Clause License)\n'
              '- Dart (BSD 3-Clause License)\n'
              '- GetX (MIT License)\n'
              '- Supabase (Apache License 2.0)\n'
              '- Cached Network Image (MIT License)\n'
              '- Iconsax (MIT License)\n'
              '- Shimmer (BSD 2-Clause License)\n'
              '- GetStorage (MIT License)\n\n'
              'For more details, visit the respective project websites.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required GlobalKey key,
    required String title,
    required IconData icon,
  }) {
    return Row(
      key: key,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
