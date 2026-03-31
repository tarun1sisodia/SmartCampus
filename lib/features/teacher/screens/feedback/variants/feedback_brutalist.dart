import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackBrutalist extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackBrutalist({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 4))
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildBrutalHeader(yellow),
              const SizedBox(height: 48),
              _buildBrutalSection('RATING_CRITERIA_01', [
                const Center(
                  child: Text('RATE_INDIVIDUAL_EXPERIENCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSel = index < controller.rating.value;
                    return GestureDetector(
                      onTap: () => controller.setRating(index + 1),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? yellow : Colors.white,
                          border: Border.all(color: Colors.black, width: 2.5),
                          boxShadow: isSel ? null : const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                        ),
                        child: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: Colors.black, size: 28),
                      ),
                    );
                  }),
                ),
              ], blue),
              const SizedBox(height: 32),
              _buildBrutalSection('REPORT_CONTENT_01', [
                const Text('QUALITATIVE_DATA_INPUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 5,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'IDENTIFY_OPTIMIZATIONS...',
                    filled: true, fillColor: Colors.white,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black, width: 2.5)),
                    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black, width: 2.5)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black, width: 4)),
                  ),
                ),
              ], orange),
              const SizedBox(height: 64),
              _buildBrutalButton(orange),
              const SizedBox(height: 32),
              const Center(child: Text('VERSION_1.2.4_STABLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildBrutalHeader(Color yellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black,
          child: const Text('FEEDBACK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: yellow,
          child: const Text('SYSTEM_USER_REPORT_STREAM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildBrutalSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildBrutalButton(Color accent) {
    return GestureDetector(
      onTap: () => controller.submitFeedback(),
      child: Container(
        height: 72,
        decoration: BoxDecoration(color: Colors.black, boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
        child: const Center(
          child: Text('TRANSMIT_REPORT_01', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
        ),
      ),
    );
  }
}
