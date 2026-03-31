import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MessagesCyberpunk extends StatelessWidget {
  const MessagesCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    final selectedCategory = 0.obs;
    const messages = [
      _MessageData('John Smith', 'Question about homework.', '10:30 AM', true, 'JS'),
      _MessageData('Sarah Johnson', 'Project feedback received.', 'Yesterday', false, 'SJ'),
      _MessageData('Michael Brown', 'Next class meeting?', 'Yesterday', true, 'MB'),
      _MessageData('Emily Davis', 'Assignment submitted.', 'Monday', false, 'ED'),
    ];

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCyberHeader(cyan, magenta),
                    const SizedBox(height: 32),
                    Obx(() => Row(
                      children: [
                        _buildCyberTab('ALL_LOGS', 0, selectedCategory.value, () => selectedCategory.value = 0, cyan),
                        const SizedBox(width: 8),
                        _buildCyberTab('UNREAD_NODES', 1, selectedCategory.value, () => selectedCategory.value = 1, magenta),
                        const SizedBox(width: 8),
                        _buildCyberTab('FAVS', 2, selectedCategory.value, () => selectedCategory.value = 2, cyan),
                      ],
                    )),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _buildCyberMessage(messages[index], cyan, magenta),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withOpacity(0.04))));
  }

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMMUNICATIONS', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2, fontFamily: 'Courier')),
        Text('CORE_UPLINK_STATUS_X01', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: cyan),
      ],
    );
  }

  Widget _buildCyberTab(String label, int index, int selected, VoidCallback onTap, Color accent) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? accent.withOpacity(0.1) : Colors.transparent, border: Border.all(color: isSelected ? accent : accent.withOpacity(0.2))),
        child: Text(label, style: TextStyle(color: isSelected ? accent : accent.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, fontFamily: 'Courier')),
      ),
    );
  }

  Widget _buildCyberMessage(_MessageData data, Color cyan, Color magenta) {
    final accent = data.isUnread ? magenta : cyan;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: accent.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: accent.withOpacity(0.1), blurRadius: 10)]),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(border: Border.all(color: accent), shape: BoxShape.circle), child: Center(child: Text(data.avatar, style: TextStyle(color: accent, fontWeight: FontWeight.w900)))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.name.toUpperCase(), style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Courier')),
                        Text(data.time, style: TextStyle(color: accent.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data.message, style: TextStyle(color: accent.withOpacity(0.6), fontSize: 13, height: 1.4, fontFamily: 'Courier'), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (data.isUnread) Container(margin: const EdgeInsets.only(left: 12), width: 8, height: 8, decoration: BoxDecoration(color: magenta, shape: BoxShape.circle, boxShadow: [BoxShadow(color: magenta.withOpacity(0.5), blurRadius: 10)])),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MessageData {
  final String name, message, time, avatar;
  final bool isUnread;
  const _MessageData(this.name, this.message, this.time, this.isUnread, this.avatar);
}
