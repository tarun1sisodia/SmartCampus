import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key, required this.dividerText});
  final String dividerText;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Divider(
            endIndent: 5,
            indent: 60,
            thickness: 0.5,
            color: dark ? TColors.lightContainer : TColors.grey,
          ),
        ),
        Text(dividerText, style: Theme.of(context).textTheme.bodyMedium),
        Flexible(
          child: Divider(
            endIndent: 60,
            indent: 5,
            thickness: 0.5,
            color: dark ? TColors.lightContainer : TColors.grey,
          ),
        ),
      ],
    );
  }
}
