import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesFluent extends StatelessWidget {
  const MessagesFluent({super.key});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    const accentColor = Color(0xFF0078D4);

    final selectedCategory = 0.obs;
    const messages = [
      _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return Container(
      color: fluentBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Messages', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
                const SizedBox(height: 24),
                Obx(() => Row(
                  children: [
                    _buildFluentTab('All Log', 0, selectedCategory.value, () => selectedCategory.value = 0, accentColor),
                    const SizedBox(width: 8),
                    _buildFluentTab('Unread', 1, selectedCategory.value, () => selectedCategory.value = 1, accentColor),
                    const SizedBox(width: 8),
                    _buildFluentTab('Flagged', 2, selectedCategory.value, () => selectedCategory.value = 2, accentColor),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildFluentMessage(messages[index], accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentTab(String label, int index, int selected, VoidCallback onTap, Color accent) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? accent : Colors.transparent, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF605E5C), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ),
    );
  }

  Widget _buildFluentMessage(_MessageData data, Color accent) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Center(child: Text(data.avatar, style: TextStyle(color: accent, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.name, style: const TextStyle(color: Color(0xFF201F1E), fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(data.time, style: const TextStyle(color: Color(0xFF605E5C), fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data.message, style: const TextStyle(color: Color(0xFF605E5C), fontSize: 13, height: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
            ],
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
