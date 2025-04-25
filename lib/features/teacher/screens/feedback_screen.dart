import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/feedback_controller.dart';

class FeedbackScreen extends StatelessWidget {
  final FeedbackController controller = Get.put(FeedbackController());

  FeedbackScreen({super.key}) {
    //print('FeedbackScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final textController = TextEditingController();

    // Set up listener to update controller when text changes
    textController.addListener(() {
      controller.updateFeedbackText(textController.text);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send Feedback',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We value your feedback!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              'Please let us know how we can improve the app to better serve your needs.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Rating section
            Text(
              'How would you rate your experience?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Star rating
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => controller.setRating(index + 1),
                      icon: Icon(
                        index < controller.rating.value
                            ? Iconsax.star1
                            : Iconsax.star,
                        color: index < controller.rating.value
                            ? Colors.amber
                            : Colors.grey,
                        size: 32,
                      ),
                    );
                  }),
                )),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Feedback text field
            Text(
              'Your Feedback',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                  borderSide: BorderSide(
                    color: dark ? TColors.yellow : TColors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () {
                            if (textController.text.trim().isEmpty) {
                              TSnackBar.showError(
                                message: 'Please enter your feedback',
                              );
                              return;
                            }

                            if (controller.rating.value == 0) {
                              TSnackBar.showError(
                                message: 'Please select a rating',
                              );
                              return;
                            }

                            // Submit feedback using the controller
                            controller.submitFeedback();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          dark ? TColors.yellow : TColors.deepPurple,
                      foregroundColor: dark ? Colors.black : Colors.white,
                    ),
                    child: controller.isSubmitting.value
                        ? const CircularProgressIndicator()
                        : const Text('Submit Feedback'),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
