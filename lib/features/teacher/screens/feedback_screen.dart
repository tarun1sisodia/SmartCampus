import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sized.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/snackbar_helper.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final feedbackController = TextEditingController();
    final RxBool isSubmitting = false.obs;
    final RxInt selectedRating = 0.obs;

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
                  onPressed: () => selectedRating.value = index + 1,
                  icon: Icon(
                    index < selectedRating.value ? Iconsax.star1 : Iconsax.star,
                    color: index < selectedRating.value ? Colors.amber : Colors.grey,
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
              controller: feedbackController,
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
                onPressed: isSubmitting.value
                    ? null
                    : () {
                        if (feedbackController.text.trim().isEmpty) {
                          TSnackBar.showError(
                            message: 'Please enter your feedback',
                          );
                          return;
                        }
                        
                        if (selectedRating.value == 0) {
                          TSnackBar.showError(
                            message: 'Please select a rating',
                          );
                          return;
                        }
                        
                        // Submit feedback
                        isSubmitting.value = true;
                        
                        // Simulate API call
                        Future.delayed(const Duration(seconds: 2), () {
                          isSubmitting.value = false;
                          TSnackBar.showSuccess(
                            message: 'Thank you for your feedback!',
                          );
                          Get.back();
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                  foregroundColor: dark ? Colors.black : Colors.white,
                ),
                child: isSubmitting.value
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
