import 'package:SmartCampus/features/teacher/controllers/feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackDialog extends StatelessWidget {
  final FeedbackController controller = Get.put(FeedbackController());

  FeedbackDialog({super.key}) {
    print('FeedbackDialog initialized');
  }

  @override
  Widget build(BuildContext context) {
    print('FeedbackDialog build method called');
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    print('FeedbackDialog contentBox method called');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'We Value Your Feedback!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'How would you rate your experience with our app?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Star Rating
          Obx(() {
            print('Star rating updated: ${controller.rating.value}');
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < controller.rating.value
                        ? Icons.star
                        : Icons.star_border,
                    color: index < controller.rating.value
                        ? Colors.amber
                        : Colors.grey,
                    size: 36,
                  ),
                  onPressed: () {
                    print('Star ${index + 1} clicked');
                    controller.setRating(index + 1);
                  },
                );
              }),
            );
          }),
          const SizedBox(height: 20),
          TextField(
            onChanged: (text) {
              print('Feedback text updated: $text');
              controller.updateFeedbackText(text);
            },
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tell us what you think (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                  Colors.grey[100],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  print('Maybe Later button clicked');
                  controller.dismissFeedback();
                },
                child: const Text('Maybe Later'),
              ),
              Obx(() {
                print(
                    'Submit button state updated: isSubmitting=${controller.isSubmitting.value}');
                return ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () {
                          print('Submit button clicked');
                          controller.submitFeedback();
                        },
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
