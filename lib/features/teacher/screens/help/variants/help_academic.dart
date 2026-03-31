import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpAcademic extends StatelessWidget {
  const HelpAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown

    return Container(
      color: paperColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        children: [
          _buildScholarHeader(accentColor, inkColor),
          const SizedBox(height: 48),
          _buildScholarSection('SUPPORT_CHANNELS', [
            _buildScholarCategory(title: 'FAQs', subtitle: 'KNOWLEDGE_BASE', icon: Iconsax.message_question, color: Colors.blue, onTap: () => _showFAQs(context, inkColor)),
            _buildScholarCategory(title: 'SUPPORT', subtitle: 'FACULTY_UPLINK', icon: Iconsax.message, color: Colors.green, onTap: () => _showContactOptions(context, inkColor)),
            _buildScholarCategory(title: 'GUIDE', subtitle: 'CURRICULAR_DOCS', icon: Iconsax.book_1, color: Colors.orange, onTap: () {}),
            _buildScholarCategory(title: 'TUTORIALS', subtitle: 'VISUAL_ARCHIVES', icon: Iconsax.video, color: Colors.red, onTap: () {}),
          ], inkColor),
          const SizedBox(height: 32),
          _buildScholarSection('PRIORITY_RESOLUTIONS', [
            _buildScholarFAQItem(question: 'How do I mark attendance?', answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there...'),
            _buildScholarFAQItem(question: 'How do I add a new student?', answer: 'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there...'),
          ], inkColor),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScholarHeader(Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assistance', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 36, fontFamily: 'Serif')),
        Text('ACADEMIC_SUPPORT_LEDGER', style: TextStyle(color: accent.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarSection(String title, List<Widget> items, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif')),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withOpacity(0.05)), boxShadow: [BoxShadow(color: ink.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildScholarCategory({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFAF7F0), border: Border.all(color: Colors.black.withOpacity(0.05))), child: Icon(icon, color: color.withOpacity(0.6), size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Serif')),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, fontFamily: 'Serif')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarFAQItem({required String question, required String answer}) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Serif', color: Colors.black87)),
        iconColor: Colors.black54,
        collapsedIconColor: Colors.black26,
        tilePadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Text(answer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black45, height: 1.5, fontFamily: 'Serif')),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context, Color ink) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF7F0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
              Text('KNOWLEDGE_LEDGER', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Serif')),
              const Divider(height: 32, thickness: 1, color: Colors.black12),
              _buildScholarFAQItem(question: 'How do I create a new class?', answer: 'To create a new class, go to the Classes tab and tap the "+" button in the bottom right corner...'),
              _buildScholarFAQItem(question: 'How do I edit a student\'s information?', answer: 'To edit a student\'s information, go to the Classes tab...'),
              _buildScholarFAQItem(question: 'How do I view attendance history?', answer: 'To view attendance history, go to the Classes tab...'),
            ],
          );
        },
      ),
    );
  }

  void _showContactOptions(BuildContext context, Color ink) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF7F0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FACULTY_UPLINK', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Serif')),
            const Divider(height: 32, thickness: 1, color: Colors.black12),
            _buildContactTile(icon: Iconsax.message, title: 'EMAIL', subtitle: 'support@smartcampus.com', color: Colors.blue),
            _buildContactTile(icon: Iconsax.call, title: 'PHONE', subtitle: '+1 (123) 456-7890', color: Colors.green),
            _buildContactTile(icon: Iconsax.global, title: 'PORTAL', subtitle: 'www.smartcampus.com/help', color: Colors.purple),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: ink, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), elevation: 0),
                child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Serif')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFAF7F0), border: Border.all(color: Colors.black.withOpacity(0.05))), child: Icon(icon, color: color.withOpacity(0.6), size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black26, letterSpacing: 1, fontFamily: 'Serif')),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Serif', color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
