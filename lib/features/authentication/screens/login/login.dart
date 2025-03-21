import 'package:flutter/material.dart';

import '../../../../common/styles/spacing_styles.dart';
import '../../../../utils/constants/sized.dart';
import '../../../../utils/constants/text_strings.dart';
import 'login_widgets/button_footer.dart';
import 'login_widgets/divider_login.dart';
import 'login_widgets/login_form.dart';
import 'login_widgets/logo_text.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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
            CustomDivider(dividerText: TTexts.orSignInWith),
            const SizedBox(height: TSizes.spaceBtwItems),
            FooterButton(),
          ],
        ),
      ),
    );
  }
}
