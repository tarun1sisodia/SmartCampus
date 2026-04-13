import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesGlassmorphism extends StatelessWidget {
  const MessagesGlassmorphism({super.key});

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: _glassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Messages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36, letterSpacing: -1)),
                    const SizedBox(height: 16),
                    _buildGlassTabs(selectedCategory),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: messages.length,
                itemBuilder: (context, index) => _buildGlassMessage(messages[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTabs(RxInt selected) {
    return Obx(() => Row(
      children: [
        _glassTab('All', 0, selected.value, () => selected.value = 0),
        const SizedBox(width: 8),
        _glassTab('Unread', 1, selected.value, () => selected.value = 1),
        const SizedBox(width: 8),
        _glassTab('Favs', 2, selected.value, () => selected.value = 2),
      ],
    ));
  }

  Widget _glassTab(String label, int index, int selected, VoidCallback onTap) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildGlassMessage(_MessageData data) {
    return Column(
      children: [
        _glassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle), child: Center(child: Text(data.avatar, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(data.time, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data.message, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white24, blurRadius: 4)])),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
}

class _MessageData {
  final String name, message, time, avatar;
  final bool isUnread;
  const _MessageData(this.name, this.message, this.time, this.isUnread, this.avatar);
}
