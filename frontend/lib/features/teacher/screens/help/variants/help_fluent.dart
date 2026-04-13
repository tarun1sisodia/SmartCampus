import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpFluent extends StatelessWidget {
  const HelpFluent({super.key});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    
    return Container(
      color: fluentBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          _buildFluentHeader(),
          const SizedBox(height: 32),
          _buildFluentSection('SUPPORT_CHANNELS', [
            _buildFluentCategory(title: 'FAQs', subtitle: 'KNOWLEDGE_BASE', icon: Iconsax.message_question, color: Colors.blue, onTap: () => _showFAQs(context)),
            _buildFluentCategory(title: 'Support', subtitle: 'CONNECT_UPLINK', icon: Iconsax.message, color: Colors.green, onTap: () => _showContactOptions(context)),
            _buildFluentCategory(title: 'Guide', subtitle: 'CORE_OPERATIONS', icon: Iconsax.book_1, color: Colors.orange, onTap: () {}),
            _buildFluentCategory(title: 'Videos', subtitle: 'VISUAL_STREAMS', icon: Iconsax.video, color: Colors.red, onTap: () {}),
          ]),
          const SizedBox(height: 24),
          _buildFluentSection('PRIORITY_RESOLUTIONS', [
            _buildFluentFAQItem(question: 'How do I mark attendance?', answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there...'),
            _buildFluentFAQItem(question: 'How do I add a new student?', answer: 'To add a new student, go to the Classes tab...'),
          ]),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFluentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        Text('ACADEMIC_KNOWLEDGE_PROTOCOL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0078D4), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildFluentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildFluentCategory({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color.withValues(alpha: 0.6), size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF201F1E))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFA19F9D), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 14, color: Color(0xFF605E5C)),
          ],
        ),
      ),
    );
  }

  Widget _buildFluentFAQItem({required String question, required String answer}) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF201F1E))),
        iconColor: const Color(0xFF0078D4),
        collapsedIconColor: const Color(0xFF605E5C),
        tilePadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(answer, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.w500, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
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
              const Text('KNOWLEDGE_BASE', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF201F1E))),
              const Divider(height: 32, thickness: 1, color: Color(0xFFF3F3F3)),
              _buildFluentFAQItem(question: 'How do I create a new class?', answer: 'To create a new class...'),
              _buildFluentFAQItem(question: 'How do I edit a student\'s information?', answer: 'To edit a student\'s information...'),
            ],
          );
        },
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CONNECT_UPLINK', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF201F1E))),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF3F3F3)),
            _buildContactTile(icon: Iconsax.message, title: 'EMAIL', subtitle: 'support@smartcampus.com', color: Colors.blue),
            _buildContactTile(icon: Iconsax.call, title: 'PHONE', subtitle: '+1 (123) 456-7890', color: Colors.green),
            _buildContactTile(icon: Iconsax.global, title: 'PORTAL', subtitle: 'www.smartcampus.com/help', color: Colors.purple),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D4), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), elevation: 0),
                child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w700)),
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
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: color.withValues(alpha: 0.6), size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFFA19F9D), letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF201F1E))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
