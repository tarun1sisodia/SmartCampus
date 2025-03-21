import 'package:attedance__/features/authentication/screens/signup/forget_reset/reset_password.dart';
import 'package:attedance__/features/authentication/screens/signup/singup_widgets/textfields.dart';
import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/image_strings.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/constants/text_strings.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        actions: [Icon(CupertinoIcons.clear)],
      ),
      body: Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            Lottie.asset(
                TImageStrings.searching, // Use your image constant
                width: THelperFunction.screenWidth() * 0.6,
              ),
              const SizedBox(height: TSizes.defaultSpace,),
            Text(
              TTexts.forgetPasswordTitle,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              TTexts.forgetPasswordSubTitle,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: TSizes.spaceBtwSections * 2),
            Textfields(
              labelText: TTexts.email,
              prefixIcon: Icon(Iconsax.direct_right),
              iconColor: dark ? TColors.yellow : TColors.deepPurple,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              height: TSizes.appBarHeight,
              child: ElevatedButton(
                onPressed: () => Get.off(() => const ResetPassword()),
                child: Text(TTexts.submit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
