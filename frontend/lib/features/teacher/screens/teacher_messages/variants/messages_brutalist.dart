import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesBrutalist extends StatelessWidget {
  const MessagesBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrutalHeader(yellow),
                const SizedBox(height: 32),
                Obx(() => Row(
                  children: [
                    _buildBrutalTab('ALL_LOGS', 0, selectedCategory.value, () => selectedCategory.value = 0, yellow),
                    const SizedBox(width: 8),
                    _buildBrutalTab('UNREAD', 1, selectedCategory.value, () => selectedCategory.value = 1, orange),
                    const SizedBox(width: 8),
                    _buildBrutalTab('FAVS', 2, selectedCategory.value, () => selectedCategory.value = 2, blue),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildBrutalMessage(messages[index], yellow, orange, blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalHeader(Color yellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black,
          child: const Text('MESSAGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: yellow,
          child: const Text('UPLINK_COMM_REGISTRY_X01', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildBrutalTab(String label, int index, int selected, VoidCallback onTap, Color accent) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? accent : Colors.white, border: Border.all(color: Colors.black, width: 2), boxShadow: isSelected ? null : const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildBrutalMessage(_MessageData data, Color yellow, Color orange, Color blue) {
    final accent = data.isUnread ? orange : yellow;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: accent, border: Border.all(color: Colors.black, width: 2), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]), child: Center(child: Text(data.avatar, style: const TextStyle(fontWeight: FontWeight.w900)))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        Text(data.time, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data.message, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black45, height: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
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
