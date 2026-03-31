import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackMaterial3 extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackMaterial3({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            children: [
              _buildM3Header(theme),
              const SizedBox(height: 32),
              _buildM3Section(theme, 'Experience Rating', [
                const Center(
                  child: Text('How would you rate your recent usage?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSel = index < controller.rating.value;
                    return IconButton.filledTonal(
                      onPressed: () => controller.setRating(index + 1),
                      icon: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.3), size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: isSel ? theme.colorScheme.primaryContainer : Colors.transparent,
                      ),
                    );
                  }),
                ),
              ]),
              const SizedBox(height: 24),
              _buildM3Section(theme, 'Detailed Report', [
                const Text('What can we improve?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 5,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Share your detailed feedback here...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 14),
                    filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5)),
                  ),
                ),
              ]),
              const SizedBox(height: 48),
              _buildM3Button(theme),
              const SizedBox(height: 32),
              Center(child: Text('Your feedback is encrypted and secure.', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold))),
              const SizedBox(height: 80),
            ],
          )),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Send Feedback', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Help us optimize the academic platform.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Section(ThemeData theme, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildM3Button(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton.icon(
        onPressed: () => controller.submitFeedback(),
        icon: const Icon(Iconsax.send_1),
        label: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
