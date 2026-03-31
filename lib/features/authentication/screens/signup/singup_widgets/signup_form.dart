import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/image_strings.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import '../../../../../common/utils/helpers/snackbar_helper.dart';
import '../../../../controllers/signup_controller.dart';
import 'textfields.dart';

class SignupForm extends StatelessWidget {
  SignupForm({super.key});

  final controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // Name field
          Textfields(
            controller: controller.nameController,
            iconColor: TColors.executiveNavy,
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

          // Phone Number
          TextFormField(
            controller: controller.phoneController,
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: TTexts.phoneNumber,
              prefixIcon: const Icon(Iconsax.call),
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
            iconColor: TColors.executiveNavy,
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
              iconColor: TColors.executiveNavy,
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

          const SizedBox(height: TSizes.spaceBtwSections),

          // Sign up button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: TSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (controller.formKey.currentState!.validate()) {
                          try {
                            await controller.signUpWithEmail();
                            Get.toNamed(
                              AppRoutes.verifyEmail,
                              arguments: controller.emailController.text.trim(),
                            );
                          } catch (e) {
                            // Handled in controller
                          }
                        } else {
                          TSnackBar.showValidationError(message: TTexts.fillCorrect);
                        }
                      },
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(TTexts.createAccount.toUpperCase()),
              ),
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
            child: Row(
              children: [
                const Expanded(child: Divider(thickness: 1.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                  child: Text(
                    TTexts.oR.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: TColors.slate600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Expanded(child: Divider(thickness: 1.5)),
              ],
            ),
          ),

          // Social Login Buttons
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: TSizes.buttonHeight,
              child: OutlinedButton.icon(
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Image.network(
                        TImageStrings.google,
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.g_mobiledata, size: 24);
                        },
                      ),
                label: Text(
                  controller.isLoading.value
                      ? 'SIGNING IN...'
                      : TTexts.orSignInWithGoogle.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : controller.signUpWithGoogle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
