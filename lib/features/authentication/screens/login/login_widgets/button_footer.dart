import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/image_strings.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';

class FooterButton extends StatelessWidget {
  const FooterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: dark ? TColors.grey : TColors.borderPrimary,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Image(
                height: TSizes.iconMd,
                width: TSizes.iconMd,
                image: AssetImage(TImageStrings.google),
              ),
            ),
          ),
          // Right Icon
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: dark ? TColors.buttonSecondary : TColors.borderPrimary,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Image(
                height: TSizes.iconMd,
                width: TSizes.iconMd,
                image: AssetImage(TImageStrings.facebook),
              ),
            ),
          ),
          // Bottom Icon
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: dark ? TColors.buttonSecondary : TColors.borderPrimary,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Image(
                height: TSizes.iconMd,
                width: TSizes.iconMd,
                color: dark ? TColors.white : TColors.dark,
                image: AssetImage(TImageStrings.apple),
              ),
            ),
          ),
          // Left Icon
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: dark ? TColors.buttonSecondary : TColors.borderPrimary,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Image(
                height: TSizes.iconMd,
                width: TSizes.iconMd,
                image: AssetImage(TImageStrings.microsoft),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
