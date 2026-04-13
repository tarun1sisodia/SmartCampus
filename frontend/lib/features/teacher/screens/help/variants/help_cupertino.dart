import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Color, FontWeight, TextStyle, BorderRadius, BoxDecoration, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, ListView, IconData, Icon, CrossAxisAlignment, VoidCallback;

class HelpCupertino extends StatelessWidget {
  const HelpCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Help & Support'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildIosHeader(),
          const SizedBox(height: 32),
          _buildIosSection('SUPPORT_RESOURCES', [
            _buildIosCategory(title: 'FAQs', icon: CupertinoIcons.question_circle, color: const Color(0xFF007AFF), onTap: () => _showFAQs(context)),
            _buildIosCategory(title: 'Support', icon: CupertinoIcons.chat_bubble, color: const Color(0xFF34C759), onTap: () => _showContactOptions(context)),
            _buildIosCategory(title: 'Guide', icon: CupertinoIcons.book, color: const Color(0xFFFF9500), onTap: () {}),
            _buildIosCategory(title: 'Tutorials', icon: CupertinoIcons.play_circle, color: const Color(0xFFFF3B30), onTap: () {}),
          ]),
          const SizedBox(height: 24),
          _buildIosSection('PRIORITY_KNOWLEDGE', [
            _buildIosFAQItem(question: 'How do I mark attendance?', answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there...'),
            _buildIosFAQItem(question: 'How do I add a new student?', answer: 'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there...'),
            _buildIosFAQItem(question: 'How do I generate reports?', answer: 'To generate reports, go to the More tab, select "Reports". From there...'),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assistance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1)),
        Text('Knowledge Hub'.toUpperCase(), style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildIosSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 12)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildIosCategory({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 22)),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w600, fontSize: 16))),
                const Icon(CupertinoIcons.chevron_right, size: 14, color: Color(0xFFC7C7CC)),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 64, color: Color(0xFFF2F2F7)),
      ],
    );
  }

  Widget _buildIosFAQItem({required String question, required String answer}) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {}, // Expansion would be better as a modal or a push in Cupertino
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Text(question, style: const TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w500, fontSize: 14))),
                const Icon(CupertinoIcons.chevron_right, size: 12, color: Color(0xFFC7C7CC)),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
      ],
    );
  }

  void _showFAQs(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Knowledge Base'),
        message: const Text('Frequently Asked Questions'),
        actions: [
          CupertinoActionSheetAction(onPressed: () {}, child: const Text('Marking Attendance')),
          CupertinoActionSheetAction(onPressed: () {}, child: const Text('Adding Students')),
          CupertinoActionSheetAction(onPressed: () {}, child: const Text('Reporting Protocol')),
        ],
        cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(context), isDefaultAction: true, child: const Text('Close')),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Connect'),
        message: const Text('Operational Support Channels'),
        actions: [
          CupertinoActionSheetAction(onPressed: () {}, child: const Text('Email Support')),
          CupertinoActionSheetAction(onPressed: () {}, child: const Text('Voice Support')),
          CupertinoActionSheetAction(onPressed: () {}, child: const Text('Visit Portal')),
        ],
        cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(context), isDestructiveAction: true, child: const Text('Cancel')),
      ),
    );
  }
}
