import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import '../../../../../common/utils/helpers/helper_function.dart';
import '../../../../../common/utils/helpers/snackbar_helper.dart';
import '../../../controllers/signup_controller.dart';
import 'textfields.dart';

class SignupForm extends StatelessWidget {
  SignupForm({super.key});

  final controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
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
              iconColor: dark ? TColors.yellow : TColors.primary,
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
            TextFormField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(
                  Iconsax.call,
                  color: dark ? TColors.yellow : TColors.primary,
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                } else if (value.length != 10) {
                  return 'Phone number must be exactly 10 digits';
                } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  return 'Phone number must contain only digits';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

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
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Password field
            Obx(
              () => Textfields(
                controller: controller.passwordController,
                iconColor: dark ? TColors.yellow : TColors.primary,
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
            // Obx(
            //   () =>
            //       controller.errorMessage.value.isNotEmpty
            //           ? Padding(
            //             padding: const EdgeInsets.only(
            //               top: TSizes.spaceBtwItems,
            //             ),
            //             child: Text(
            //               controller.errorMessage.value,
            //               style: const TextStyle(color: Colors.red),
            //             ),
            //           )
            //           : const SizedBox.shrink(),
            // ),
            const SizedBox(height: TSizes.appBarHeight),

            // Sign up button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: TSizes.appBarHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              await controller.signUpWithEmail();

                              // Navigate to email verification screen using named route
                              Get.toNamed(
                                AppRoutes.verifyEmail,
                                arguments:
                                    controller.emailController.text.trim(),
                              );
                            } catch (e) {
                              // Error is already handled in the controller with custom snackbar
                            }
                          } else {
                            // Show validation error if form is not valid
                            TSnackBar.showValidationError(
                              message:
                                  'Please fill in all required fields correctly.',
                            );
                          }
                        },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text(TTexts.createAccount,
                          style: TextStyle(
                            color: dark ? TColors.primary : Colors.white,
                            fontSize: TSizes.fontSizeMd,
                            fontWeight: FontWeight.bold,
                          )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
