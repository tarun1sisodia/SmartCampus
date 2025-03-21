import 'package:attedance__/features/authentication/screens/login/login_widgets/button_footer.dart';
import 'package:attedance__/features/authentication/screens/login/login_widgets/divider_login.dart';
import 'package:attedance__/features/authentication/screens/signup/singup_widgets/signup_form.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../utils/constants/sized.dart';
import '../../../../../utils/constants/text_strings.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TTexts.createAccount,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SignupForm(),
              const SizedBox(height: TSizes.spaceBtwSections),
              CustomDivider(dividerText: TTexts.orSignUpWith.capitalize!),
              const SizedBox(height: TSizes.spaceBtwSections),
              FooterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
