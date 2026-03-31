import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesMaterial3 extends StatelessWidget {
  const MessagesMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = 0.obs;
    final theme = Theme.of(context);
    const messages = [
      _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messages', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 24),
                Obx(() => Row(
                  children: [
                    _m3Tab('All', 0, selectedCategory.value, () => selectedCategory.value = 0, theme),
                    const SizedBox(width: 8),
                    _m3Tab('Unread', 1, selectedCategory.value, () => selectedCategory.value = 1, theme),
                    const SizedBox(width: 8),
                    _m3Tab('Starred', 2, selectedCategory.value, () => selectedCategory.value = 2, theme),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildM3Message(messages[index], theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _m3Tab(String label, int index, int selected, VoidCallback onTap, ThemeData theme) {
    final isSelected = index == selected;
    if (isSelected) {
      return FilterChip(label: Text(label), selected: true, onSelected: (_) => onTap(), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
    }
    return ActionChip(label: Text(label), onPressed: onTap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
  }

  Widget _buildM3Message(_MessageData data, ThemeData theme) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: data.isUnread ? theme.colorScheme.primaryContainer.withOpacity(0.3) : theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Text(data.avatar, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer))),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: data.isUnread ? FontWeight.bold : FontWeight.normal)),
                Text(data.time, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(child: Text(data.message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (data.isUnread) Badge(backgroundColor: theme.colorScheme.primary, label: null),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _MessageData {
  final String name, message, time, avatar;
  final bool isUnread;
  const _MessageData(this.name, this.message, this.time, this.isUnread, this.avatar);
}
