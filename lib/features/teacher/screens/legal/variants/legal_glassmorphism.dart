import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalGlassmorphism extends StatefulWidget {
  final String initialSection;
  const LegalGlassmorphism({super.key, required this.initialSection});

  @override
  State<LegalGlassmorphism> createState() => _LegalGlassmorphismState();
}

class _LegalGlassmorphismState extends State<LegalGlassmorphism> {
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
            _buildGlassSection(
              key: _sectionKeys['privacy_policy']!,
              title: 'PRIVACY_POLICY',
              icon: Iconsax.shield_tick,
              content: 'Last Updated: [05/05/2025]\n\nWe respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.',
            ),
            const SizedBox(height: 32),
            _buildGlassSection(
              key: _sectionKeys['terms_of_service']!,
              title: 'TERMS_OF_SERVICE',
              icon: Iconsax.document_text,
              content: 'Last Updated: [05/05/2025]\n\nBy accessing or using SmartCampus, you agree to be bound by these Terms of Service.',
            ),
            const SizedBox(height: 32),
            _buildGlassSection(
              key: _sectionKeys['open_source_licenses']!,
              title: 'OPEN_SOURCE_MODULES',
              icon: Iconsax.code,
              content: 'SmartCampus is built using various open-source software components. Acknowledgments include:\n\n- Flutter (BSD 3-Clause License)\n- Dart (BSD 3-Clause License)\n- GetX (MIT License)',
            ),
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
        const Text('Legal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36, letterSpacing: -1)),
        Text('COMPLIANCE_PROTOCOL_UPLINK', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildGlassSection({required GlobalKey key, required String title, required IconData icon, required String content}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
            ],
          ),
        ),
        _glassContainer(
          padding: const EdgeInsets.all(28),
          child: Text(content, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14, height: 1.6)),
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
}
