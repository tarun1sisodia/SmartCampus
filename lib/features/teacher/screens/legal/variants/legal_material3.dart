import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalMaterial3 extends StatefulWidget {
  final String initialSection;
  const LegalMaterial3({super.key, required this.initialSection});

  @override
  State<LegalMaterial3> createState() => _LegalMaterial3State();
}

class _LegalMaterial3State extends State<LegalMaterial3> {
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
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildM3Header(theme),
          const SizedBox(height: 32),
          _buildM3Section(
            key: _sectionKeys['privacy_policy']!,
            theme: theme,
            title: 'Privacy Policy',
            icon: Iconsax.shield_tick,
            content: 'Last Updated: [05/05/2025]\n\nWe respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.',
          ),
          const SizedBox(height: 24),
          _buildM3Section(
            key: _sectionKeys['terms_of_service']!,
            theme: theme,
            title: 'Terms of Service',
            icon: Iconsax.document_text,
            content: 'Last Updated: [05/05/2025]\n\nBy accessing or using SmartCampus, you agree to be bound by these Terms of Service.',
          ),
          const SizedBox(height: 24),
          _buildM3Section(
            key: _sectionKeys['open_source_licenses']!,
            theme: theme,
            title: 'Open Source Licenses',
            icon: Iconsax.code,
            content: 'SmartCampus is built using various open-source software components. Acknowledgments include:\n\n- Flutter (BSD 3-Clause License)\n- Dart (BSD 3-Clause License)\n- GetX (MIT License)',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legal', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Regulatory compliance and governance.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Section({required GlobalKey key, required ThemeData theme, required String title, required IconData icon, required String content}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 12),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(content, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.6)),
          ),
        ),
      ],
    );
  }
}
