import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpCorporate extends StatelessWidget {
  const HelpCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          const Text('SYSTEM_SUPPORT_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
          const SizedBox(height: 24),
          _buildHelpCategory(
            title: 'FREQUENT_ISSUES_FAQ',
            icon: Iconsax.message_question,
            color: const Color(0xFF3B82F6),
            onTap: () => _showFAQs(context),
          ),
          _buildHelpCategory(
            title: 'CONTACT_ADMIN_SUPPORT',
            icon: Iconsax.message,
            color: const Color(0xFF10B981),
            onTap: () => _showContactOptions(context),
          ),
          _buildHelpCategory(
            title: 'OPERATIONAL_MANUAL',
            icon: Iconsax.book_1,
            color: const Color(0xFFF59E0B),
            onTap: () {},
          ),
          _buildHelpCategory(
            title: 'VISUAL_TUTORIAL_STREAM',
            icon: Iconsax.video,
            color: const Color(0xFFEF4444),
            onTap: () {},
          ),
          const SizedBox(height: 48),
          const Text('PRIORITY_RESOLUTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'How do I mark attendance?',
            answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there, you can create a new session and mark students as present, absent, or late.',
          ),
          _buildFAQItem(
            question: 'How do I add a new student?',
            answer: 'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there, you can tap the "+" button to add a new student to the class.',
          ),
          _buildFAQItem(
            question: 'How do I generate reports?',
            answer: 'To generate reports, go to the More tab, select "Reports". From there, you can choose the type of report you want to generate and export it in your preferred format.',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHelpCategory({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), border: Border.all(color: color.withValues(alpha: 0.2))), child: Icon(icon, color: color, size: 24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B), letterSpacing: 1)),
        trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
      child: ExpansionTile(
        title: Text(question.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF1E293B), letterSpacing: 1)),
        iconColor: const Color(0xFF0F172A),
        collapsedIconColor: const Color(0xFF94A3B8),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569), height: 1.5)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              const Text('GENERAL_KNOWLEDGE_BASE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A), letterSpacing: 1)),
              const Divider(height: 32, thickness: 2, color: Color(0xFF0F172A)),
              _buildFAQItem(question: 'How do I create a new class?', answer: 'To create a new class, go to the Classes tab and tap the "+" button in the bottom right corner. Fill in the class details and tap "Create".'),
              _buildFAQItem(question: 'How do I edit a student\'s information?', answer: 'To edit a student\'s information, go to the Classes tab, select a class, then tap on "Students". Find the student you want to edit, tap on their name, and then tap the edit button.'),
              _buildFAQItem(question: 'How do I view attendance history?', answer: 'To view attendance history, go to the Classes tab, select a class, then tap on "Attendance". You will see a list of all attendance sessions for that class.'),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CONTACT_CHANNELS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A), letterSpacing: 1)),
            const Divider(height: 32, thickness: 2, color: Color(0xFF0F172A)),
            _buildContactTile(icon: Iconsax.message, title: 'EMAIL_SUPPORT', subtitle: 'support@smartcampus.com', color: Colors.blue),
            _buildContactTile(icon: Iconsax.call, title: 'VOICE_SUPPORT', subtitle: '+1 (123) 456-7890', color: Colors.green),
            _buildContactTile(icon: Iconsax.global, title: 'WEB_PORTAL', subtitle: 'www.smartcampus.com/help', color: Colors.purple),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0F172A), width: 2), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                child: const Text('DISMISS_OVERLAY', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({required IconData icon, required String title, required String subtitle, required Color color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), border: Border.all(color: color.withValues(alpha: 0.2))), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF1E293B), letterSpacing: 1)),
      subtitle: Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
    );
  }
}
