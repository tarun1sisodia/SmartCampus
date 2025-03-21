import 'package:attedance__/utils/constants/image_strings.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/constants/text_strings.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';


class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Lottie.asset(
                TImageStrings.hello_robo, // Use your image constant
                width: THelperFunction.screenWidth() * 0.6,
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              /// Title & Subtitle
              Text(
                TTexts.passwordResetEmailSent,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: TSizes.spaceBtwItems),
              Text(
                TTexts.changePasswordSubTitle,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              /// Buttons
              SizedBox(
                width: double.infinity,
                height: TSizes.appBarHeight,
                child: ElevatedButton(
                  onPressed: () => Get.to(()),
                  child: const Text(TTexts.continueText),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),
              SizedBox(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    TTexts.resendEmail,
                    style: Theme.of(context).textTheme.bodyMedium,
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
