import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpGlassmorphism extends StatelessWidget {
  const HelpGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          children: [
            _buildGlassHeader(),
            const SizedBox(height: 48),
            _buildGlassSection('SUPPORT_CHANNELS', [
              _buildHelpCategory(title: 'FAQs', subtitle: 'KNOWLEDGE_BASE', icon: Iconsax.message_question, color: Colors.blue[300]!, onTap: () => _showFAQs(context)),
              _buildHelpCategory(title: 'SUPPORT', subtitle: 'CONTACT_UPLINK', icon: Iconsax.message, color: Colors.green[300]!, onTap: () => _showContactOptions(context)),
              _buildHelpCategory(title: 'GUIDE', subtitle: 'CORE_OPERATIONS', icon: Iconsax.book_1, color: Colors.orange[300]!, onTap: () {}),
              _buildHelpCategory(title: 'VIDEO', subtitle: 'VISUAL_STREAMS', icon: Iconsax.video, color: Colors.red[300]!, onTap: () {}),
            ]),
            const SizedBox(height: 32),
            _buildGlassSection('PRIORITY_KNOWLEDGE', [
              _buildFAQItem(question: 'How do I mark attendance?', answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there, you can create a new session and mark students as present, absent, or late.'),
              _buildFAQItem(question: 'How do I add a new student?', answer: 'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there, you can tap the "+" button to add a new student to the class.'),
              _buildFAQItem(question: 'How do I generate reports?', answer: 'To generate reports, go to the More tab, select "Reports". From there, you can choose the type of report you want to generate and export it in your preferred format.'),
            ]),
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
        const Text('Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36, letterSpacing: -1)),
        Text('CENTRAL_KNOWLEDGE_UPLINK', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildGlassSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
        ),
        _glassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(children: items),
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
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHelpCategory({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, size: 16, color: Colors.white.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white24,
        tilePadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(answer, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w500, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(color: Color(0xFF1E1E2E).withValues(alpha: 0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.all(32),
          child: ListView(
            children: [
              const Text('KNOWLEDGE_BASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5)),
              const SizedBox(height: 32),
              _buildFAQItem(question: 'How do I create a new class?', answer: 'To create a new class, go to the Classes tab and tap the "+" button in the bottom right corner. Fill in the class details and tap "Create".'),
              _buildFAQItem(question: 'How do I edit a student\'s information?', answer: 'To edit a student\'s information, go to the Classes tab, select a class, then tap on "Students". Find the student you want to edit, tap on their name, and then tap the edit button.'),
              _buildFAQItem(question: 'How do I view attendance history?', answer: 'To view attendance history, go to the Classes tab, select a class, then tap on "Attendance". You will see a list of all attendance sessions for that class.'),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF1E1E2E).withValues(alpha: 0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('CONTACT_UPLINK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(height: 32),
              _buildContactTile(icon: Iconsax.message, title: 'EMAIL', subtitle: 'support@smartcampus.com', color: Colors.blue),
              _buildContactTile(icon: Iconsax.call, title: 'VOICE', subtitle: '+1 (123) 456-7890', color: Colors.green),
              _buildContactTile(icon: Iconsax.global, title: 'PORTAL', subtitle: 'www.smartcampus.com/help', color: Colors.purple),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1), foregroundColor: Colors.white70, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
