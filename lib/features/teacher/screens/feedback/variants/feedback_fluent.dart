import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackFluent extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackFluent({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    
    return Container(
      color: fluentBg,
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            children: [
              _buildFluentHeader(),
              const SizedBox(height: 32),
              _buildFluentSection('EXPERIENCE RATING', [
                const Center(
                  child: Text('Rate your interaction with the system:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF201F1E))),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSel = index < controller.rating.value;
                    return IconButton(
                      onPressed: () => controller.setRating(index + 1),
                      icon: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? const Color(0xFF0078D4) : const Color(0xFFA19F9D), size: 36),
                    );
                  }),
                ),
              ]),
              const SizedBox(height: 24),
              _buildFluentSection('REPORT DETAILS', [
                const Text('Provide details for optimization:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF605E5C))),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 5,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF201F1E)),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts here...',
                    hintStyle: const TextStyle(color: Color(0xFFA19F9D), fontSize: 14),
                    filled: true, fillColor: const Color(0xFFF3F3F3).withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0078D4), width: 1.5)),
                  ),
                ),
              ]),
              const SizedBox(height: 48),
              _buildFluentButton(),
              const SizedBox(height: 32),
              const Center(child: Text('VERSION 1.2.4 • SECURE', style: TextStyle(color: Color(0xFFA19F9D), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildFluentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Feedback', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        Text('SYSTEM_UPLINK_PROTOCOL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0078D4), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildFluentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
        ),
      ],
    );
  }

  Widget _buildFluentButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => controller.submitFeedback(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0078D4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        child: const Text('SUBMIT_REPORT_UPLINK', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
      ),
    );
  }
}
