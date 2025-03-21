import 'package:attedance__/features/authentication/controllers/signup_controller.dart';
import 'package:attedance__/features/authentication/screens/signup/singup_widgets/textfields.dart';
import 'package:attedance__/routes/app_routes.dart';
import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/constants/text_strings.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SignupForm extends StatelessWidget {
  SignupForm({super.key});

  final controller = Get.find<SignupController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.spaceBtwSections,
          vertical: TSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            // Name field
            Textfields(
              controller: controller.nameController,
              iconColor: dark ? TColors.yellow : TColors.deepPurple,
              prefixIcon: const Icon(Iconsax.user),
              labelText: TTexts.firstName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            //Phone Number
            Textfields(
              controller: controller.phoneController,
              iconColor: dark ? TColors.yellow : TColors.deepPurple,
              prefixIcon: const Icon(Iconsax.call),
              labelText: TTexts.phoneNumber,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Email field
            Textfields(
              controller: controller.emailController,
              iconColor: dark ? TColors.yellow : TColors.deepPurple,
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
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Password field
            Obx(
              () => Textfields(
                controller: controller.passwordController,
                iconColor: dark ? TColors.yellow : TColors.deepPurple,
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: TTexts.password,
                obscureText: !controller.passwordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.passwordVisible.value
                        ? Iconsax.eye
                        : Iconsax.eye_slash,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),

            // Error message
            Obx(
              () =>
                  controller.errorMessage.value.isNotEmpty
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

            const SizedBox(height: TSizes.appBarHeight),

            // Sign up button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: TSizes.appBarHeight,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await controller.signUpWithEmail();

                                // Navigate to email verification screen using named route
                                Get.toNamed(
                                  AppRoutes.verifyEmail,
                                  arguments:
                                      controller.emailController.text.trim(),
                                );
                              } catch (e) {
                                // Error is already handled in the controller
                              }
                            }
                          },
                  child:
                      controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : Text(TTexts.createAccount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
