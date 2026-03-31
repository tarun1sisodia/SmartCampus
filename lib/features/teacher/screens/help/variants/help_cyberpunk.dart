import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpCyberpunk extends StatelessWidget {
  const HelpCyberpunk({super.key});

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
              _buildCyberSection('SUPPORT_UPLINK_CHANNELS', [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildCyberCategory(title: 'FAQs', icon: Iconsax.message_question, color: cyan, onTap: () => _showFAQs(context, cyan, magenta)),
                    _buildCyberCategory(title: 'SUPPORT', icon: Iconsax.message, color: magenta, onTap: () => _showContactOptions(context, cyan, magenta)),
                    _buildCyberCategory(title: 'GUIDE', icon: Iconsax.book_1, color: cyan, onTap: () {}),
                    _buildCyberCategory(title: 'VIDEO', icon: Iconsax.video, color: magenta, onTap: () {}),
                  ],
                ),
              ], cyan),
              const SizedBox(height: 32),
              _buildCyberSection('KNOWLEDGE_BYTE_STREAM', [
                _buildCyberFAQItem(question: 'How do I mark attendance?', answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there...', color: cyan),
                _buildCyberFAQItem(question: 'How do I add a new student?', answer: 'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there...', color: magenta),
                _buildCyberFAQItem(question: 'How do I generate reports?', answer: 'To generate reports, go to the More tab, select "Reports". From there...', color: cyan),
              ], magenta),
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
        Text('SUPPORT', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2, fontFamily: 'Courier')),
        Text('CORE_KNOWLEDGE_PROTOCOL', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: cyan),
      ],
    );
  }

  Widget _buildCyberSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: accent.withOpacity(0.3), width: 1.5)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildCyberCategory({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.black, border: Border.all(color: color.withOpacity(0.3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Courier')),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberFAQItem({required String question, required String answer, required Color color}) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Courier')),
        iconColor: color,
        collapsedIconColor: color.withOpacity(0.3),
        tilePadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(answer, style: TextStyle(color: color.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13, height: 1.5, fontFamily: 'Courier')),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context, Color cyan, Color magenta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(side: BorderSide(color: cyan, width: 2), borderRadius: const BorderRadius.vertical(top: Radius.circular(0))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(32),
            children: [
              const Text('KNOWLEDGE_UPLINK_X01', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, fontFamily: 'Courier')),
              const Divider(height: 32, thickness: 1, color: Color(0xFF00F5FF)),
              _buildCyberFAQItem(question: 'How do I create a new class?', answer: 'To create a new class, go to the Classes tab and tap the "+" button in the bottom right corner...', color: cyan),
              _buildCyberFAQItem(question: 'How do I edit a student\'s information?', answer: 'To edit a student\'s information, go to the Classes tab...', color: magenta),
              _buildCyberFAQItem(question: 'How do I view attendance history?', answer: 'To view attendance history, go to the Classes tab...', color: cyan),
            ],
          );
        },
      ),
    );
  }

  void _showContactOptions(BuildContext context, Color cyan, Color magenta) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(side: BorderSide(color: magenta, width: 2), borderRadius: const BorderRadius.vertical(top: Radius.circular(0))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CONNECT_UPLINK_X01', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, fontFamily: 'Courier')),
            const Divider(height: 32, thickness: 1, color: Color(0xFFFF00CC)),
            _buildContactTile(icon: Iconsax.message, title: 'EMAIL', subtitle: 'support@smartcampus.com', color: cyan),
            _buildContactTile(icon: Iconsax.call, title: 'VOICE', subtitle: '+1 (123) 456-7890', color: magenta),
            _buildContactTile(icon: Iconsax.global, title: 'PORTAL', subtitle: 'www.smartcampus.com/help', color: cyan),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 60,
                decoration: BoxDecoration(color: magenta.withOpacity(0.1), border: Border.all(color: magenta, width: 2)),
                child: const Center(child: Text('DISMISS_OVERLAY', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier'))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3))), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color.withOpacity(0.4), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1, fontFamily: 'Courier')),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Courier')),
              ],
            ),
          ),
        ],
      ),
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
