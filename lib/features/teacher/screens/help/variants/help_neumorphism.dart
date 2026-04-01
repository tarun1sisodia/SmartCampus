import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:iconsax/iconsax.dart';

class HelpNeumorphism extends StatelessWidget {
  const HelpNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);
    
    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          _buildNeuHeader(),
          const SizedBox(height: 48),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 12),
            child: Text('SUPPORT_CHANNELS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _buildNeuCategory(title: 'FAQs', icon: Iconsax.message_question, color: Colors.blue, onTap: () => _showFAQs(context), bg: bgColor),
              _buildNeuCategory(title: 'SUPPORT', icon: Iconsax.message, color: Colors.green, onTap: () => _showContactOptions(context), bg: bgColor),
              _buildNeuCategory(title: 'GUIDE', icon: Iconsax.book_1, color: Colors.orange, onTap: () {}, bg: bgColor),
              _buildNeuCategory(title: 'TUTORIALS', icon: Iconsax.video, color: Colors.red, onTap: () {}, bg: bgColor),
            ],
          ),
          const SizedBox(height: 48),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 12),
            child: Text('KNOWLEDGE_STREAM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
          ),
          _buildNeuFAQSection(bgColor, [
            _buildNeuFAQItem(question: 'How do I mark attendance?', answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there...'),
            _buildNeuFAQItem(question: 'How do I add a new student?', answer: 'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there...'),
            _buildNeuFAQItem(question: 'How do I generate reports?', answer: 'To generate reports, go to the More tab, select "Reports". From there...'),
          ]),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNeuHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Support', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Color(0xFF4D565F), letterSpacing: -1)),
        Text('SYSTEM_KNOWLEDGE_HUB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuCategory({required String title, required IconData icon, required Color color, required VoidCallback onTap, required Color bg}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.6), size: 32),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF4D565F), letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuFAQSection(Color bg, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNeuFAQItem({required String question, required String answer}) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF4D565F))),
        iconColor: const Color(0xFF6D5DFC),
        collapsedIconColor: const Color(0xFFA3B1C6),
        tilePadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Text(answer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4D565F), height: 1.5, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFE0E5EC),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
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
              const Text('KNOWLEDGE_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF4D565F))),
              const SizedBox(height: 32),
              _buildNeuFAQItem(question: 'How do I create a new class?', answer: 'To create a new class, go to the Classes tab and tap the "+" button in the bottom right corner...'),
              _buildNeuFAQItem(question: 'How do I edit a student\'s information?', answer: 'To edit a student\'s information, go to the Classes tab...'),
              _buildNeuFAQItem(question: 'How do I view attendance history?', answer: 'To view attendance history, go to the Classes tab...'),
            ],
          );
        },
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE0E5EC),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('CONTACT_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF4D565F))),
            const SizedBox(height: 32),
            _buildContactTile(icon: Iconsax.message, title: 'EMAIL', subtitle: 'support@smartcampus.com', color: Colors.blue),
            _buildContactTile(icon: Iconsax.call, title: 'VOICE', subtitle: '+1 (123) 456-7890', color: Colors.green),
            _buildContactTile(icon: Iconsax.global, title: 'PORTAL', subtitle: 'www.smartcampus.com/help', color: Colors.purple),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                    BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 8),
                  ],
                ),
                child: const Center(child: Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6D5DFC)))),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E5EC),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8, inset: true),
                BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 8, inset: true),
              ],
            ),
            child: Icon(icon, color: color.withValues(alpha: 0.6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF4D565F))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
