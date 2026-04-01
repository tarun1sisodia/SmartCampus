import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesCorporate extends StatelessWidget {
  const MessagesCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = 0.obs;
    final messages = [
      const _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      const _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      const _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      const _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('COMMUNICATION_REGISTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
                const SizedBox(height: 24),
                Obx(() => Row(
                  children: [
                    _buildCategoryTab('ALL_LOGS', 0, selectedCategory.value, () => selectedCategory.value = 0),
                    const SizedBox(width: 8),
                    _buildCategoryTab('UNREAD_NODES', 1, selectedCategory.value, () => selectedCategory.value = 1),
                    const SizedBox(width: 8),
                    _buildCategoryTab('SECURED_PRIORITY', 2, selectedCategory.value, () => selectedCategory.value = 2),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildCorporateMessage(messages[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String label, int index, int selected, VoidCallback onTap) {
    final isSelected = index == selected;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF0F172A) : Colors.transparent, border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0))),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: isSelected ? Colors.white : const Color(0xFF64748B), letterSpacing: 1)),
      ),
    );
  }

  Widget _buildCorporateMessage(_MessageData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: const Color(0xFF0F172A).withValues(alpha: 0.1), border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.2))),
          child: Center(child: Text(data.avatar, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)))),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
            Text(data.time, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8))),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(child: Text(data.message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (data.isUnread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}

class _MessageData {
  final String name, message, time, avatar;
  final bool isUnread;
  const _MessageData(this.name, this.message, this.time, this.isUnread, this.avatar);
}
