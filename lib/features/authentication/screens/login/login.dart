import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/utils/constants/image_strings.dart';
import '../../../../common/utils/constants/sized.dart';
import '../../../../common/utils/constants/text_strings.dart';
import '../../controllers/login_controller.dart';
import 'login_widgets/login_form.dart';
import 'login_widgets/logo_text.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            //for logo
            LogoAndText(),
            const SizedBox(height: TSizes.spaceBtwItems),
            LoginForm(),
            // const SizedBox(height: TSizes.spaceBtwItems),
            // RememberAndForget(
            //   initialValue: controller.rememberMe.value,
            //   onRememberChanged: controller.setRememberMe,
            // ),
            // const SizedBox(height: TSizes.spaceBtwItems),
            // CustomDivider(dividerText: TTexts.orSignInWith),
            // const SizedBox(height: TSizes.spaceBtwItems),
            // this at the bottom of your form, after the Sign up button
            const SizedBox(height: TSizes.sm),
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
                  icon: controller.isGoogleLoading.value
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
                    controller.isGoogleLoading.value
                        ? 'Signing in...'
                        : TTexts.orSignInWithGoogle,
                  ),
                  onPressed: controller.isGoogleLoading.value
                      ? null
                      : controller.signInWithGoogle,
                ),
              ),
            ),

            // FooterButton(),
          ],
        ),
      ),),
    );
  }
}
