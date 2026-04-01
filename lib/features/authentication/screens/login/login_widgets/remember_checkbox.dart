import 'package:smart_campus/features/authentication/screens/forgot_password/forgot_password_2.dart';

import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import '../../../../../common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RememberAndForget extends StatelessWidget {
  final ValueChanged<bool> onRememberChanged;
  final bool value;

  const RememberAndForget({
    super.key,
    required this.onRememberChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // some responsive and adpative code for small --- big ui screens
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              activeColor: dark ? TColors.buttonPrimary : TColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) => onRememberChanged(value ?? false),
            ),
            Text(
              TTexts.rememberMe,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        TextButton(
          onPressed: () => Get.to(() => ForgotPassword()),
          child: Text(
            TTexts.forgotPassword,
            style: TextStyle(
              color: dark ? TColors.buttonPrimary : TColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
