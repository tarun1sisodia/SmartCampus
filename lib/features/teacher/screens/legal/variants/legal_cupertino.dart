import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, Badge, CircleAxis, CircleAvatar, TextSelectionTheme, TextSelectionThemeData, TextFormField, InputDecoration, InputBorder, OutlineInputBorder, FileImage, Chip;

class LegalCupertino extends StatefulWidget {
  final String initialSection;
  const LegalCupertino({super.key, required this.initialSection});

  @override
  State<LegalCupertino> createState() => _LegalCupertinoState();
}

class _LegalCupertinoState extends State<LegalCupertino> {
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
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Legal Information'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildIosHeader(),
          const SizedBox(height: 32),
          _buildIosSection(
            key: _sectionKeys['privacy_policy']!,
            title: 'PRIVACY_POLICY',
            icon: CupertinoIcons.shield_fill,
            content: 'Last Updated: [05/05/2025]\n\nWe respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.',
          ),
          const SizedBox(height: 24),
          _buildIosSection(
            key: _sectionKeys['terms_of_service']!,
            title: 'TERMS_OF_SERVICE',
            icon: CupertinoIcons.doc_text_fill,
            content: 'Last Updated: [05/05/2025]\n\nBy accessing or using SmartCampus, you agree to be bound by these Terms of Service.',
          ),
          const SizedBox(height: 24),
          _buildIosSection(
            key: _sectionKeys['open_source_licenses']!,
            title: 'OPEN_SOURCE_LICENSE_REGISTRY',
            icon: CupertinoIcons.slash_circle_fill,
            content: 'SmartCampus is built using various open-source software components. Acknowledgments include:\n\n- Flutter (BSD 3-Clause License)\n- Dart (BSD 3-Clause License)\n- GetX (MIT License)',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Legal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1)),
        Text('Regulatory Registry'.toUpperCase(), style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildIosSection({required GlobalKey key, required String title, required IconData icon, required String content}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 12)),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Text(content, style: const TextStyle(color: Color(0xFF3C3C43), fontSize: 14, height: 1.5)),
        ),
      ],
    );
  }
}
