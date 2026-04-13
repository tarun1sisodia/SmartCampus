import '../../../../common/utils/constants/text_strings.dart';
import '../../controllers/forgot_password_controller.dart';
import 'package:smart_campus/app/routes/app_routes.dart'; // Import the routes
import 'package:smart_campus/common/utils/constants/image_strings.dart';
import 'package:smart_campus/common/utils/constants/sized.dart';
import 'package:smart_campus/common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ResetPasswordConfirmationScreen extends StatelessWidget {
  final String email;

  const ResetPasswordConfirmationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    // Find the controller - it should be registered in the binding
    final controller = Get.find<ForgotPasswordController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () =>
                Get.offAllNamed(AppRoutes.login), // Use named route
            icon: Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Image.network(
                TImageStrings.verifyemail,
                width: THelperFunction.screenWidth() * 0.6,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                'Check Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                email,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'We have sent a password reset link to your email. Please check your inbox and follow the instructions to reset your password.',
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Back to Login button
              SizedBox(
                height: TSizes.appBarHeight,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Get.offAllNamed(AppRoutes.login), // Use named route
                  child: Text(
                    'Back to Login',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Resend email button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            try {
                              controller.emailController.text = email;
                              await controller.resetPassword();
                              Get.snackbar(
                                'Email Sent',
                                'Password reset email has been resent',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } catch (e) {
                              Get.snackbar(
                                TTexts.error,
                                'Failed to resend password reset email',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Resend Email',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
