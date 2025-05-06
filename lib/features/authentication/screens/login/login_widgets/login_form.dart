import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/constants/text_strings.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/signup_controller.dart';
import '../../../controllers/supabase_auth_controller.dart';
import '../../signup/singup_widgets/textfields.dart';
import 'remember_checkbox.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final controller = Get.put(SupabaseAuthController());
  final _formKey = GlobalKey<FormState>();
  final _passwordVisible = false.obs;

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
                obscureText: !_passwordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible.value ? Iconsax.eye : Iconsax.eye_slash,
                  ),
                  onPressed: () =>
                      _passwordVisible.value = !_passwordVisible.value,
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

            SizedBox(height: TSizes.spaceBtwInputFields / 2),
            RememberAndForget(
              initialValue: controller.rememberMe.value,
              onRememberChanged: controller.setRememberMe,
            ),

            const SizedBox(height: TSizes.appBarHeight),

            // Sign in button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: TSizes.appBarHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TSizes.borderRadiusMd,
                      ),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            if (controller.emailController.text.isNotEmpty &&
                                controller.passwordController.text.isNotEmpty) {
                              controller.signInWithEmail();
                            }
                          }
                        },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text(
                          TTexts.signIn,
                          style: TextStyle(
                            color: dark ? TColors.primary : Colors.white,
                            fontSize: TSizes.fontSizeMd,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),
            // Create account button
            SizedBox(
              width: double.infinity,
              height: TSizes.appBarHeight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                  ),
                ),
                onPressed: () {
                  // Clean up any existing SignupController
                  if (Get.isRegistered<SignupController>()) {
                    Get.delete<SignupController>(force: true);
                  }
                  Get.toNamed('/signup');
                },
                child: Text(
                  TTexts.createAccount,
                  style: TextStyle(
                    color: dark ? TColors.yellow : TColors.primary,
                    fontSize: TSizes.fontSizeMd,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
