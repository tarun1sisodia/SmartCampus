import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpMinimalist extends StatelessWidget {
  const HelpMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        children: [
          const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: Colors.black87, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Your guide to a seamless academic journey.', style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5)),
          const SizedBox(height: 48),
          _buildHelpCategory(
            title: 'FAQs',
            subtitle: 'Get answers to common questions',
            icon: Iconsax.message_question,
            color: Colors.blue[400]!,
            onTap: () => _showFAQs(context),
          ),
          _buildHelpCategory(
            title: 'Support',
            subtitle: 'Connect with our team',
            icon: Iconsax.message,
            color: Colors.green[400]!,
            onTap: () => _showContactOptions(context),
          ),
          _buildHelpCategory(
            title: 'User Guide',
            subtitle: 'Learn the core features',
            icon: Iconsax.book_1,
            color: Colors.orange[400]!,
            onTap: () {},
          ),
          _buildHelpCategory(
            title: 'Tutorials',
            subtitle: 'Watch step-by-step videos',
            icon: Iconsax.video,
            color: Colors.red[400]!,
            onTap: () {},
          ),
          const SizedBox(height: 48),
          Text('Key Topics', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black.withOpacity(0.6))),
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

  Widget _buildHelpCategory({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black.withOpacity(0.3))),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, size: 18, color: Colors.black.withOpacity(0.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
        iconColor: Colors.black,
        collapsedIconColor: Colors.grey[200],
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Text(answer, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black.withOpacity(0.4), height: 1.6)),
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
              const Text('FAQs', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24, color: Colors.black87)),
              const SizedBox(height: 32),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connect', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24, color: Colors.black87)),
            const SizedBox(height: 32),
            _buildContactTile(icon: Iconsax.message, title: 'Email', subtitle: 'support@smartcampus.com', color: Colors.blue),
            _buildContactTile(icon: Iconsax.call, title: 'Phone', subtitle: '+1 (123) 456-7890', color: Colors.green),
            _buildContactTile(icon: Iconsax.global, title: 'Web', subtitle: 'www.smartcampus.com/help', color: Colors.purple),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFFBFBFB), foregroundColor: Colors.black54, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
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
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
