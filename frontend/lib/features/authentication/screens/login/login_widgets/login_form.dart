import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import '../../../controllers/login_controller.dart';
import '../../../controllers/signup_controller.dart';
import '../../signup/signup.dart';
import '../../signup/singup_widgets/textfields.dart';
import 'remember_checkbox.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: loginController.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.spaceBtwSections,
          vertical: TSizes.spaceBtwItems,
        ),
        child: Column(
          children: [
            // Email field
            Textfields(
              controller: loginController.email,
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
                controller: loginController.password,
                iconColor: TColors.executiveNavy,
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: TTexts.password,
                obscureText: !loginController.passwordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    loginController.passwordVisible.value
                        ? Iconsax.eye
                        : Iconsax.eye_slash,
                  ),
                  onPressed: loginController.togglePasswordVisibility,
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

            const SizedBox(height: TSizes.spaceBtwInputFields / 2),
            Obx(
              () => RememberAndForget(
                value: loginController.rememberMe.value,
                onRememberChanged: (val) => loginController.rememberMe.value = val ?? false,
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Sign in button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: TSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: loginController.isLoading.value
                      ? null
                      : () => loginController.login(),
                  child: loginController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(TTexts.signIn.toUpperCase()),
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),
            // Create account button (Commented out if it's teacher-only but keeping for UI)
            SizedBox(
              width: double.infinity,
              height: TSizes.buttonHeight,
              child: OutlinedButton(
                onPressed: () {
                  if (Get.isRegistered<SignupController>()) {
                    Get.delete<SignupController>(force: true);
                  }
                  Get.to(Signup());
                },
                child: Text(TTexts.createAccount.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
