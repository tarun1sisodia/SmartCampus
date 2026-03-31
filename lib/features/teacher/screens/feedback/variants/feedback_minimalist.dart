import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/feedback_controller.dart';

class FeedbackMinimalist extends StatelessWidget {
  final FeedbackController controller;
  final TextEditingController textController = TextEditingController();

  FeedbackMinimalist({super.key, required this.controller}) {
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Obx(() => controller.isSubmitting.value
        ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            children: [
              const Text('Feedback', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: Colors.black87, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Your insights help us refine the academic experience.', style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5)),
              const SizedBox(height: 48),
              Text('How was your experience?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black.withOpacity(0.6))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isSel = index < controller.rating.value;
                  return IconButton(
                    onPressed: () => controller.setRating(index + 1),
                    icon: Icon(isSel ? Iconsax.star1 : Iconsax.star, color: isSel ? Colors.black : Colors.grey[200], size: 36),
                  );
                }),
              ),
              const SizedBox(height: 48),
              Text('Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black.withOpacity(0.6))),
              const SizedBox(height: 16),
              TextFormField(
                controller: textController,
                maxLines: 5,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
                  filled: true, fillColor: const Color(0xFFFBFBFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[100]!, width: 1)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[100]!, width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 1)),
                ),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextButton(
                  onPressed: () => controller.submitFeedback(),
                  style: TextButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
              Center(child: Text('Analytics help us grow.', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500))),
            ],
          )),
    );
  }
}
