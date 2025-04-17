import 'package:SmartCampus/features/authentication/screens/login/login_widgets/button_footer.dart';
import 'package:SmartCampus/features/authentication/screens/login/login_widgets/divider_login.dart';
import 'package:SmartCampus/features/authentication/screens/signup/singup_widgets/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SmartCampus/common/utils/constants/sized.dart';
import 'package:SmartCampus/common/utils/constants/text_strings.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                TTexts.createAccount,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Signup Form
              SignupForm(),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Divider
              CustomDivider(dividerText: TTexts.orSignUpWith.capitalize!),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Social Login Buttons
              FooterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
