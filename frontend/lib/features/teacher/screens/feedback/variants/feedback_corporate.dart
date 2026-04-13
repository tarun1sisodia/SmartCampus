import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackCorporate extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackCorporate({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              const Text('SYSTEM_USER_EXPERIENCE_REPORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
              const SizedBox(height: 24),
              _buildSection([
                const Text('METRIC_RATING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8), letterSpacing: 1)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSel = index < controller.rating.value;
                    return IconButton(
                      onPressed: () => controller.setRating(index + 1),
                      icon: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0), size: 32),
                    );
                  }),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection([
                const Text('REPORT_DETAILS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8), letterSpacing: 1)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 6,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'IDENTIFY_ISSUES_OR_SUGGEST_MODIFICATIONS...',
                    filled: true, fillColor: Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF0F172A), width: 2)),
                  ),
                ),
              ]),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => controller.submitFeedback(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), elevation: 0),
                  child: const Text('TRANSMIT_REPORT_STREAM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),
              const SizedBox(height: 24),
              const Center(child: Text('DATA_WILL_BE_ENCRYPTED_UPON_SUBMISSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8), letterSpacing: 1))),
            ],
          )),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
