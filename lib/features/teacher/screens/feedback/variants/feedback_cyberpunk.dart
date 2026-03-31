import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackCyberpunk extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackCyberpunk({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          Obx(() => controller.isSubmitting.value
            ? const Center(child: CircularProgressIndicator(color: cyan))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                children: [
                  _buildCyberHeader(cyan, magenta),
                  const SizedBox(height: 48),
                  _buildCyberSection('QUALITATIVE_RATING_UPLINK', [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: Text('RATE_USER_EXPERIENCE_METRIC', style: TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier')),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isSel = index < controller.rating.value;
                        return IconButton(
                          onPressed: () => controller.setRating(index + 1),
                          icon: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? cyan : cyan.withOpacity(0.1), size: 36),
                        );
                      }),
                    ),
                  ], cyan),
                  const SizedBox(height: 32),
                  _buildCyberSection('REPORT_CONTENT_NODE', [
                    const Text('DETAIL_SPECIFICATIONS', style: TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier')),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: textController,
                      maxLines: 5,
                      style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Courier'),
                      decoration: InputDecoration(
                        hintText: 'IDENTIFY_OPTIMIZATIONS...',
                        hintStyle: TextStyle(color: cyan.withOpacity(0.2), fontSize: 14, fontFamily: 'Courier'),
                        filled: true, fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan.withOpacity(0.3))),
                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan, width: 1.5)),
                      ),
                    ),
                  ], magenta),
                  const SizedBox(height: 64),
                  _buildCyberButton(cyan, magenta),
                  const SizedBox(height: 32),
                  Center(child: Text('UPLINK_STATUS: SECURE_STABLE', style: TextStyle(color: cyan.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, fontFamily: 'Courier'))),
                  const SizedBox(height: 100),
                ],
              )),
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
        Text('TRANSMIT', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2, fontFamily: 'Courier')),
        Text('FEEDBACK_REPORT_PROTOCOL', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: cyan),
      ],
    );
  }

  Widget _buildCyberSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: accent.withOpacity(0.3), width: 1.5)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildCyberButton(Color cyan, Color magenta) {
    return GestureDetector(
      onTap: () => controller.submitFeedback(),
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: magenta.withOpacity(0.1), border: Border.all(color: magenta, width: 2), boxShadow: [BoxShadow(color: magenta.withOpacity(0.2), blurRadius: 10)]),
        child: Center(
          child: Text('INITIALIZE_UPLINK_TRANSMIT', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2, fontFamily: 'Courier')),
        ),
      ),
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
      canvas.drawLine(Offset(0, i), Offset(size.height, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
