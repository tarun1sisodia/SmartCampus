import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LegalCyberpunk extends StatefulWidget {
  final String initialSection;
  const LegalCyberpunk({super.key, required this.initialSection});

  @override
  State<LegalCyberpunk> createState() => _LegalCyberpunkState();
}

class _LegalCyberpunkState extends State<LegalCyberpunk> {
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
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            children: [
              _buildCyberHeader(cyan, magenta),
              const SizedBox(height: 48),
              _buildCyberSection(
                key: _sectionKeys['privacy_policy']!,
                title: 'PRIVACY_MANIFEST_X01',
                icon: Iconsax.shield_tick,
                content: 'WE RESPECT YOUR PRIVACY. DATA SECURITY IS ENFORCED VIA SUPABASE ENCRYPTION PROTOCOLS.',
                color: cyan,
              ),
              const SizedBox(height: 32),
              _buildCyberSection(
                key: _sectionKeys['terms_of_service']!,
                title: 'TERMS_OF_ENGAGEMENT_X01',
                icon: Iconsax.document_text,
                content: 'BY ENGAGING WITH SMARTCAMPUS, YOU AGREE TO SYSTEM PROTOCOLS AND OPERATIONAL BOUNDARIES.',
                color: magenta,
              ),
              const SizedBox(height: 32),
              _buildCyberSection(
                key: _sectionKeys['open_source_licenses']!,
                title: 'DEPENDENCY_REGISTRY_X01',
                icon: Iconsax.code,
                content: 'SYSTEM BUILT ON FLUTTER / DART / GETX / SUPABASE KERNEL.',
                color: cyan,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withOpacity(0.04))));
  }

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REGULATORY', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2, fontFamily: 'Courier')),
        Text('COMPLIANCE_MANIFEST_PROTOCOL', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: cyan),
      ],
    );
  }

  Widget _buildCyberSection({required GlobalKey key, required String title, required IconData icon, required String content, required Color color}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: color.withOpacity(0.3), width: 1.5)),
          child: Text(content, style: TextStyle(color: color.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13, height: 1.6, fontFamily: 'Courier')),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
