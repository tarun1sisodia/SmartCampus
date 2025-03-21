import 'package:attedance__/features/authentication/screens/forgot_password/forgot_password_2.dart';

import '../../signup/forget_reset/forget_password.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RememberAndForget extends StatelessWidget {
  const RememberAndForget({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(value: true, onChanged: (value) {}),
            Text(TTexts.rememberMe),
          ],
        ),
        TextButton(
          onPressed: () => Get.to(ForgotPasswordScreen()),
          child: Text(
            style: TextStyle(color: dark ? TColors.buttonPrimary : TColors.red),
            TTexts.forgotPassword,
          ),
        ),
      ],
    );
  }
}
