import 'package:flutter/material.dart';
import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import '../../../../../common/utils/helpers/helper_function.dart';

class TermsPolicy extends StatelessWidget {
  const TermsPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(value: true, onChanged: (value) {}),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${TTexts.iAgreeTo} ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: '${TTexts.privacyPolicy} ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? TColors.white : TColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? TColors.white : TColors.primary,
                ),
              ),
              TextSpan(
                text: TTexts.and,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: ' ${TTexts.termsOfUse} ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? TColors.white : TColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? TColors.white : TColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
