import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/image_strings.dart';
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

    return Form(
      key: controller.formKey,
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
                  return TTexts.pleaseEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            //Phone Number
            TextFormField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                labelText: TTexts.phoneNumber,
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
                  return TTexts.pleaseEnterPhone;
                } else if (value.length != 10) {
                  return TTexts.phone10dgt;
                } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  return TTexts.phoneONLYdgt;
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
                  return TTexts.pleaseEnterEmail;
                }
                if (!GetUtils.isEmail(value)) {
                  return TTexts.pleaseEnterValidEmail;
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
                    return TTexts.pleaseEnterPassword;
                  }
                  if (value.length < 6) {
                    return TTexts.passwordLength;
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
                          if (controller.formKey.currentState!.validate()) {
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
                                message: TTexts.fillCorrect);
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
            // this at the bottom of your form, after the Sign up button
            const SizedBox(height: TSizes.spaceBtwSections),
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                  child: Text(TTexts.oR,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: TSizes.appBarHeight,
                child: OutlinedButton.icon(
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: TSizes.iconMd,
                          height: TSizes.iconMd,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Image.network(
                          TImageStrings.google,
                          height: TSizes.iconLg,
                          width: TSizes.iconLg,
                          cacheWidth: TSizes.iconLg.toInt(),
                          cacheHeight: TSizes.iconLg.toInt(),
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.g_mobiledata,
                              size: TSizes.iconLg,
                            );
                          },
                        ),
                  label: Text(
                    controller.isLoading.value
                        ? 'Signing in...'
                        : TTexts.orSignInWithGoogle,
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.signUpWithGoogle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
