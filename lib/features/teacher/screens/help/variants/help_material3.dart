import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpMaterial3 extends StatelessWidget {
  const HelpMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildM3Header(theme),
          const SizedBox(height: 32),
          _buildM3Section(theme, 'Support Channels', [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildM3Category(theme, title: 'FAQs', icon: Iconsax.message_question, color: Colors.blue, onTap: () => _showFAQs(context)),
                _buildM3Category(theme, title: 'Support', icon: Iconsax.message, color: Colors.green, onTap: () => _showContactOptions(context)),
                _buildM3Category(theme, title: 'Guide', icon: Iconsax.book_1, color: Colors.orange, onTap: () {}),
                _buildM3Category(theme, title: 'Videos', icon: Iconsax.video, color: Colors.red, onTap: () {}),
              ],
            ),
          ]),
          const SizedBox(height: 24),
          _buildM3Section(theme, 'Knowledge Stream', [
            _buildM3FAQItem(theme, question: 'How do I mark attendance?', answer: 'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there...'),
            _buildM3FAQItem(theme, question: 'How do I add a new student?', answer: 'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there...'),
            _buildM3FAQItem(theme, question: 'How do I generate reports?', answer: 'To generate reports, go to the More tab, select "Reports". From there...'),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Help & Support', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Central hub for academic assistance.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Section(ThemeData theme, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildM3Category(ThemeData theme, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildM3FAQItem(ThemeData theme, {required String question, required String answer}) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
            child: Text(answer, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
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
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 32),
              Text('FAQs', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _buildM3FAQItem(theme, question: 'How do I create a new class?', answer: 'To create a new class, go to the Classes tab and tap the "+" button in the bottom right corner...'),
              _buildM3FAQItem(theme, question: 'How do I edit a student\'s information?', answer: 'To edit a student\'s information, go to the Classes tab...'),
              _buildM3FAQItem(theme, question: 'How do I view attendance history?', answer: 'To view attendance history, go to the Classes tab...'),
            ],
          );
        },
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Channels', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildContactTile(theme, icon: Iconsax.message, title: 'Email Support', subtitle: 'support@smartcampus.com', color: Colors.blue),
            _buildContactTile(theme, icon: Iconsax.call, title: 'Phone Support', subtitle: '+1 (123) 456-7890', color: Colors.green),
            _buildContactTile(theme, icon: Iconsax.global, title: 'Visit Portal', subtitle: 'www.smartcampus.com/help', color: Colors.purple),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(ThemeData theme, {required IconData icon, required String title, required String subtitle, required Color color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
