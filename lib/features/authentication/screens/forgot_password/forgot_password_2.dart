import '../../../../app/routes/app_routes.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../../../common/utils/constants/image_strings.dart';
import '../../../../common/utils/constants/sized.dart';
import '../../../../common/utils/constants/text_strings.dart';
import '../../../../common/utils/helpers/helper_function.dart';
import '/../features/authentication/controllers/forgot_password_controller.dart';
import '/../features/authentication/screens/signup/singup_widgets/textfields.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
    final formKey = GlobalKey<FormState>();
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              Image(
                image: AssetImage(
                  TImageStrings.verifyemail,
                ), // Use an appropriate image
                width: THelperFunction.screenWidth() * 0.6,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Title
              Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Subtitle
              Text(
                'Enter your email and we\'ll send you a link to reset your password',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Form
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Email field
                    Textfields(
                      controller: controller.emailController,
                      iconColor: dark ? TColors.yellow : TColors.primary,
                      prefixIcon: const Icon(Iconsax.direct_right),
                      labelText: TTexts.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    // Error message
                    Obx(
                      () => controller.errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: TSizes.spaceBtwItems,
                              ),
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Submit button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: TSizes.appBarHeight,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    try {
                                      await controller.resetPassword();
                                      // Navigate using named route and pass the email
                                      Get.toNamed(
                                        AppRoutes.resetConfirmation,
                                        arguments: controller
                                            .emailController.text
                                            .trim(),
                                      );
                                    } catch (e) {
                                      // Error is already handled in the controller
                                    }
                                  }
                                },
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator()
                              : Text('Reset Password'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
