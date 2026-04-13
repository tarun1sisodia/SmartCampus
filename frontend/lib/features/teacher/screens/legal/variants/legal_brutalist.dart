import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalBrutalist extends StatefulWidget {
  final String initialSection;
  const LegalBrutalist({super.key, required this.initialSection});

  @override
  State<LegalBrutalist> createState() => _LegalBrutalistState();
}

class _LegalBrutalistState extends State<LegalBrutalist> {
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
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildBrutalHeader(yellow),
          const SizedBox(height: 48),
          _buildBrutalSection(
            key: _sectionKeys['privacy_policy']!,
            title: 'PRIVACY_PROTOCOL',
            icon: Iconsax.shield_tick,
            content: 'WE RESPECT YOUR PRIVACY. DATA COLLECTED IS USED EXCLUSIVELY FOR ACADEMIC TRACKING AND AUTHENTICATION.',
            accent: blue,
          ),
          const SizedBox(height: 32),
          _buildBrutalSection(
            key: _sectionKeys['terms_of_service']!,
            title: 'TERMS_OF_SERVICE',
            icon: Iconsax.document_text,
            content: 'BY USING THIS SYSTEM, YOU AGREE TO THE BOUNDARIES OF ACADEMIC GOVERNANCE.',
            accent: orange,
          ),
          const SizedBox(height: 32),
          _buildBrutalSection(
            key: _sectionKeys['open_source_licenses']!,
            title: 'SYSTEM_KERNEL_LICENSES',
            icon: Iconsax.code,
            content: 'SYSTEM BUILT ON OPEN SOURCE KERNELS: FLUTTER, DART, GETX, SUPABASE.',
            accent: yellow,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBrutalHeader(Color yellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black,
          child: const Text('LEGAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: yellow,
          child: const Text('REGULATORY_COMPLIANCE_X01', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildBrutalSection({required GlobalKey key, required String title, required IconData icon, required String content, required Color accent}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
          child: Text(content, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black, height: 1.5)),
        ),
      ],
    );
  }
}
