import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesMinimalist extends StatelessWidget {
  const MessagesMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = 0.obs;
    const messages = [
      _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Messages', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: Colors.black87, letterSpacing: -0.5)),
                const SizedBox(height: 24),
                Obx(() => Row(
                  children: [
                    _buildCategoryBtn('All', 0, selectedCategory.value, () => selectedCategory.value = 0),
                    const SizedBox(width: 12),
                    _buildCategoryBtn('Unread', 1, selectedCategory.value, () => selectedCategory.value = 1),
                    const SizedBox(width: 12),
                    _buildCategoryBtn('Important', 2, selectedCategory.value, () => selectedCategory.value = 2),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMinimalMessage(messages[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBtn(String label, int index, int selected, VoidCallback onTap) {
    final isSelected = index == selected;
    return InkWell(
      onTap: onTap,
      child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13, color: isSelected ? Colors.black : Colors.grey[400])),
    );
  }

  Widget _buildMinimalMessage(_MessageData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)), child: Center(child: Text(data.avatar, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87)),
                    Text(data.time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(data.message, style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

class _MessageData {
  final String name, message, time, avatar;
  final bool isUnread;
  const _MessageData(this.name, this.message, this.time, this.isUnread, this.avatar);
}
