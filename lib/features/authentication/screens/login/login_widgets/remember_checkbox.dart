import '../../../../../common/utils/constants/colors.dart';
import '../../../../../common/utils/constants/text_strings.dart';
import '../../../../../common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../forgot_password/forgot_password_2.dart';

class RememberAndForget extends StatefulWidget {
  final Function(bool) onRememberChanged;
  final bool initialValue;

  const RememberAndForget({
    super.key,
    required this.onRememberChanged,
    required this.initialValue,
  });

  @override
  State<RememberAndForget> createState() => _RememberAndForgetState();
}

class _RememberAndForgetState extends State<RememberAndForget> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // add some responsive and adpative code for small --- big ui screens
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isChecked,
              activeColor: dark ? TColors.buttonPrimary : TColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) {
                setState(() {
                  _isChecked = value ?? false;
                });
                widget.onRememberChanged(_isChecked);
              },
            ),
            Text(
              TTexts.rememberMe,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        TextButton(
          onPressed: () => Get.to(() => ForgotPasswordScreen()),
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
