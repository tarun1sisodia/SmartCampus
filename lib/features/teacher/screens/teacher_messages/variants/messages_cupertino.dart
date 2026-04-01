import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, Badge, CircleAxis, CircleAvatar, TextSelectionTheme, TextSelectionThemeData, TextFormField, InputDecoration, InputBorder, OutlineInputBorder, FileImage, Chip;
import 'package:iconsax/iconsax.dart';

class MessagesCupertino extends StatelessWidget {
  const MessagesCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = 0.obs;
    const messages = [
      _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Messages'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildIosHeader(),
          const SizedBox(height: 32),
          _iosCategoryTabs(selectedCategory),
          const SizedBox(height: 24),
          _buildIosMessageSection(messages),
        ],
      ),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1)),
        Text('Communication Hub'.toUpperCase(), style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _iosCategoryTabs(RxInt selected) {
    return Obx(() => Row(
      children: [
        _iosTab('All', 0, selected.value, () => selected.value = 0),
        const SizedBox(width: 8),
        _iosTab('Unread', 1, selected.value, () => selected.value = 1),
        const SizedBox(width: 8),
        _iosTab('Fav', 2, selected.value, () => selected.value = 2),
      ],
    ));
  }

  Widget _iosTab(String label, int index, int selected, VoidCallback onTap) {
    final isSelected = index == selected;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF007AFF) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF007AFF), fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildIosMessageSection(List<_MessageData> messages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 8),
          child: Text('RECENT_LOGS', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 12)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: messages.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return Column(
                children: [
                  _iosMessageCell(data),
                  if (index < messages.length - 1) const Divider(height: 1, indent: 64, color: Color(0xFFF2F2F7)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _iosMessageCell(_MessageData data) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.1), radius: 24, child: Text(data.avatar, style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data.name, style: const TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(data.time, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(data.message, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle)),
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
