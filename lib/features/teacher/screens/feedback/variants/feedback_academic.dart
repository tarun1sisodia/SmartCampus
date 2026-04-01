import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackAcademic extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackAcademic({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown

    return Container(
      color: paperColor,
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CircularProgressIndicator(color: accentColor))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            children: [
              _buildScholarHeader(accentColor, inkColor),
              const SizedBox(height: 48),
              _buildScholarSection('QUALITATIVE_ASSESSMENT', [
                const Center(
                  child: Text('Rate your scholarly experience:', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 13, fontStyle: FontStyle.italic, fontFamily: 'Serif')),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSel = index < controller.rating.value;
                    return IconButton(
                      onPressed: () => controller.setRating(index + 1),
                      icon: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? accentColor : inkColor.withValues(alpha: 0.1), size: 36),
                    );
                  }),
                ),
              ], inkColor),
              const SizedBox(height: 32),
              _buildScholarSection('FACULTY_NOTES', [
                const Text('QUALITATIVE_OBSERVATIONS', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Serif')),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 5,
                  style: TextStyle(color: inkColor, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Serif'),
                  decoration: InputDecoration(
                    hintText: 'Enter your formal observations...',
                    hintStyle: TextStyle(color: inkColor.withValues(alpha: 0.2), fontSize: 14, fontFamily: 'Serif'),
                    filled: true, fillColor: const Color(0xFFFAF7F0).withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.4), width: 1.5)),
                  ),
                ),
              ], inkColor),
              const SizedBox(height: 64),
              _buildScholarButton(inkColor),
              const SizedBox(height: 32),
              const Center(child: Text('EDITION 1.2.4 • ARCHIVAL_SECURE', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif'))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildScholarHeader(Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Feedback', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 36, fontFamily: 'Serif')),
        Text('SYSTEM_OPTIMIZATION_LEDGER', style: TextStyle(color: accent.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarSection(String title, List<Widget> items, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif')),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: ink.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildScholarButton(Color ink) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => controller.submitFeedback(),
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.all(16),
          elevation: 0,
        ),
        child: const Text('SUBMIT_FORMAL_FACULTY_REPORT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Serif')),
      ),
    );
  }
}
