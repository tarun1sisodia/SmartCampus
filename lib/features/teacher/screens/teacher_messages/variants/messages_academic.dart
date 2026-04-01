import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesAcademic extends StatelessWidget {
  const MessagesAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513);

    final selectedCategory = 0.obs;
    const messages = [
      _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return Container(
      color: paperColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScholarHeader(accentColor, inkColor),
                const SizedBox(height: 32),
                Obx(() => Row(
                  children: [
                    _buildScholarTab('ALL_ARCHIVES', 0, selectedCategory.value, () => selectedCategory.value = 0, inkColor),
                    const SizedBox(width: 12),
                    _buildScholarTab('UNREAD', 1, selectedCategory.value, () => selectedCategory.value = 1, inkColor),
                    const SizedBox(width: 12),
                    _buildScholarTab('IMPORTANT', 2, selectedCategory.value, () => selectedCategory.value = 2, inkColor),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildScholarMessage(messages[index], inkColor, accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarHeader(Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Messages', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 36, fontFamily: 'Serif')),
        Text('INSTITUTIONAL_LOG_HUB', style: TextStyle(color: accent.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarTab(String label, int index, int selected, VoidCallback onTap, Color ink) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: TextStyle(color: isSelected ? ink : ink.withValues(alpha: 0.3), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 11, letterSpacing: 1.5, fontFamily: 'Serif')),
    );
  }

  Widget _buildScholarMessage(_MessageData data, Color ink, Color accent) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: ink.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: ink.withValues(alpha: 0.05), shape: BoxShape.circle), child: Center(child: Text(data.avatar, style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontFamily: 'Serif')))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.name.toUpperCase(), style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Serif')),
                        Text(data.time, style: TextStyle(color: ink.withValues(alpha: 0.3), fontSize: 10, fontFamily: 'Serif')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data.message, style: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 13, height: 1.4, fontFamily: 'Serif'), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MessageData {
  final String name, message, time, avatar;
  final bool isUnread;
  const _MessageData(this.name, this.message, this.time, this.isUnread, this.avatar);
}
