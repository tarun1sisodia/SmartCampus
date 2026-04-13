import 'package:flutter/material.dart';
import 'package:smart_campus/common/utils/constants/sized.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/common/utils/helpers/helper_function.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image, title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [
          Image(
            width: THelperFunction.screenWidth() * 0.8,
            height: THelperFunction.screenHeight() * 0.6,
            image: AssetImage(image),
          ),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5, color: TColors.slate900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            subtitle.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: TColors.slate600, letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}