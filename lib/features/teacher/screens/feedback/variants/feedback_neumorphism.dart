import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackNeumorphism extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackNeumorphism({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);
    
    return Container(
      color: bgColor,
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFA3B1C6)))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            children: [
              _buildNeuHeader(),
              const SizedBox(height: 48),
              _buildNeuSection(bgColor, 'EXPERIENCE_RATING', [
                const Center(
                  child: Text('QUALITATIVE_METRIC', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSel = index < controller.rating.value;
                    return GestureDetector(
                      onTap: () => controller.setRating(index + 1),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          boxShadow: isSel ? [
                            BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8, inset: true),
                            BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8, inset: true),
                          ] : [
                            BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8),
                            BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8),
                          ],
                        ),
                        child: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? const Color(0xFF6D5DFC) : const Color(0xFFA3B1C6), size: 24),
                      ),
                    );
                  }),
                ),
              ]),
              const SizedBox(height: 32),
              _buildNeuSection(bgColor, 'REPORT_DATA', [
                const Text('QUALITATIVE_DETAILS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8, inset: true),
                      BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8, inset: true),
                    ],
                  ),
                  child: TextFormField(
                    controller: textController,
                    maxLines: 5,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF4D565F)),
                    decoration: const InputDecoration(
                      hintText: 'DESCRIBE_OPTIMIZATIONS...',
                      hintStyle: TextStyle(color: Color(0xFFA3B1C6), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 64),
              _buildNeuButton(bgColor),
              const SizedBox(height: 32),
              const Center(child: Text('UPLINK_ENCRYPTED_V01', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildNeuHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Feedback', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Color(0xFF4D565F), letterSpacing: -1)),
        Text('SYSTEM_UPLINK_HUB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuSection(Color bg, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _buildNeuButton(Color bg) {
    return GestureDetector(
      onTap: () => controller.submitFeedback(),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
          ],
        ),
        child: const Center(
          child: Text('TRANSMIT_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6D5DFC), fontSize: 14, letterSpacing: 2)),
        ),
      ),
    );
  }
}
