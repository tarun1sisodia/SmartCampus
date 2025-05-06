import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/styles/spacing_styles.dart';
import '../../../../common/utils/constants/sized.dart';
import '../../controllers/login_controller.dart';
import 'login_widgets/login_form.dart';
import 'login_widgets/logo_text.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: TSpacingStyles.paddingWithAppBarHeight,
        child: Column(
          children: [
            //for logo
            LogoAndText(),
            const SizedBox(height: TSizes.spaceBtwItems),
            LoginForm(),
            const SizedBox(height: TSizes.spaceBtwItems),
            // RememberAndForget(
            //   initialValue: controller.rememberMe.value,
            //   onRememberChanged: controller.setRememberMe,
            // ),
            // const SizedBox(height: TSizes.spaceBtwItems),
            // CustomDivider(dividerText: TTexts.orSignInWith),
            // const SizedBox(height: TSizes.spaceBtwItems),
            // FooterButton(),
          ],
        ),
      ),
    );
  }
}
