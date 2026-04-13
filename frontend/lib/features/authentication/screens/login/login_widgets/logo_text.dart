import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/image_strings.dart';
import '../../../../../common/utils/constants/sized.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class LogoAndText extends StatelessWidget {
  const LogoAndText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: AssetImage(
            TImageStrings.applogoTransparentPNG,
          ),
          height: 80,
        ),
        Text(
          TTexts.logintitle1.toUpperCase(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: TSizes.xs),
        Text(
          TTexts.loginsubtitle1,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: TColors.slate600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
