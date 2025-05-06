import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/utils/constants/image_strings.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import '../../../../../common/utils/helpers/helper_function.dart';
import '../../login/login.dart';

class EmailSuccess extends StatelessWidget {
  const EmailSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    ////print("EmailSuccess screen built"); // Debugging ////print

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              ////print("Clear button pressed"); // Debugging ////print
              Get.offAll(() => Login());
            },
            icon: Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(TImageStrings.successemail),
                width: THelperFunction.screenWidth() * 0.8,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                TTexts.registrationSuccess,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                TTexts.emailVerified,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                height: TSizes.appBarHeight,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ////print("Continue button pressed"); // Debugging ////print
                    Get.to(() => Login());
                  },
                  child: Text(
                    TTexts.continueText,
                    style: Theme.of(context).textTheme.headlineSmall,
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
