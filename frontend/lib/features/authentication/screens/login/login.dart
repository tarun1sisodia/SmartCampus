import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/utils/constants/colors.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.spaceBtwSections),
          child: Column(
            children: [
              // Logo and Header
              LogoAndText(),
              
              LoginForm(),

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
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: TColors.slate600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1.5)),
                  ],
                ),
              ),

              // Social Sign-In
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: TSizes.buttonHeight,
                  child: OutlinedButton.icon(
                    icon: controller.isGoogleLoading.value
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
                      controller.isGoogleLoading.value
                          ? 'SIGNING IN...'
                          : TTexts.orSignInWithGoogle.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    onPressed: controller.isGoogleLoading.value
                        ? null
                        : controller.signInWithGoogle,
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
