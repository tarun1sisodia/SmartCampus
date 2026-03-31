import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';

class MessagesNeumorphism extends StatelessWidget {
  const MessagesNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = 0.obs;
    const bgColor = Color(0xFFE0E5EC);
    const messages = [
      _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return Container(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Messages', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Color(0xFF4D565F), letterSpacing: -1)),
                const SizedBox(height: 24),
                Obx(() => Row(
                  children: [
                    _buildNeuTab('ALL', 0, selectedCategory.value, () => selectedCategory.value = 0, bgColor),
                    const SizedBox(width: 8),
                    _buildNeuTab('UNREAD', 1, selectedCategory.value, () => selectedCategory.value = 1, bgColor),
                    const SizedBox(width: 8),
                    _buildNeuTab('FAV', 2, selectedCategory.value, () => selectedCategory.value = 2, bgColor),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildNeuMessage(messages[index], bgColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuTab(String label, int index, int selected, VoidCallback onTap, Color bgColor) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
            BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
          ] : [
            const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
            const BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: isSelected ? Colors.indigo : const Color(0xFFA3B1C6), letterSpacing: 1)),
      ),
    );
  }

  Widget _buildNeuMessage(_MessageData data, Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                    BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
                  ],
                ),
                child: Center(child: Text(data.avatar, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4D565F)))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4D565F))),
                        Text(data.time, style: const TextStyle(color: Color(0xFFA3B1C6), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data.message, style: const TextStyle(color: Color(0xFFA3B1C6), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 10, height: 10, decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent, blurRadius: 4)])),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MessageData {
  final String name, message, time, avatar;
  final bool isUnread;
  const _MessageData(this.name, this.message, this.time, this.isUnread, this.avatar);
}
