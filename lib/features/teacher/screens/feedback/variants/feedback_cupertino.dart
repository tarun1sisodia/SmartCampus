import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Color, FontWeight, TextStyle, BorderRadius, BoxDecoration, Widget, EdgeInsets, Column, Row, SizedBox, BuildContext, StatelessWidget, Center, ListView, Icon, MainAxisAlignment, CrossAxisAlignment;
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackCupertino extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackCupertino({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Feedback'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CupertinoActivityIndicator())
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            children: [
              _buildIosHeader(),
              const SizedBox(height: 32),
              _buildIosSection('EXPERIENCE RATING', [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('How would you rate the app?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSel = index < controller.rating.value;
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.setRating(index + 1),
                      child: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? const Color(0xFF007AFF) : const Color(0xFFC7C7CC), size: 36),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ]),
              const SizedBox(height: 24),
              _buildIosSection('FEEDBACK DETAILS', [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Report', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF8E8E93))),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        controller: textController,
                        maxLines: 5,
                        placeholder: 'Share your thoughts with our team...',
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        placeholderStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 15),
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 48),
              _buildIosButton(),
              const SizedBox(height: 32),
              const Center(child: Text('VERSION 1.2.4 • ENCRYPTED', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5))),
              const SizedBox(height: 80),
            ],
          )),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1)),
        Text('Optimization Insights'.toUpperCase(), style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildIosSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildIosButton() {
    return CupertinoButton(
      color: const Color(0xFF007AFF),
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(16),
      onPressed: () => controller.submitFeedback(),
      child: const Text('Transmit Report', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
    );
  }
}
