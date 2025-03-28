import 'package:attedance__/features/authentication/controllers/signup_controller.dart';
import 'package:attedance__/features/authentication/screens/login/login_widgets/button_footer.dart';
import 'package:attedance__/features/authentication/screens/login/login_widgets/divider_login.dart';
import 'package:attedance__/features/authentication/screens/signup/singup_widgets/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/constants/text_strings.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
      // Clean up before navigating back
      if (Get.isRegistered<SignupController>()) {
        Get.delete<SignupController>(force: true);
      }
      Get.back();
    },),
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