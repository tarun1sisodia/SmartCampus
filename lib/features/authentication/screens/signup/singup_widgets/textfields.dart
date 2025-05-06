import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';

class Textfields extends StatelessWidget {
  const Textfields({
    super.key,
    this.suffixIcon,
    this.expands = false,
    required this.labelText,
    required this.prefixIcon,
    required this.iconColor,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSaved,
  });

  final String labelText;
  final Icon prefixIcon;
  final Widget? suffixIcon;
  final bool expands;
  final Color iconColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // Get the current theme's InputDecorationTheme
    // final inputTheme = Theme.of(context).inputDecorationTheme;

    return TextFormField(
      controller: controller,
      expands: expands,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      decoration: InputDecoration(
        // Apply the theme's border properties
        // border: inputTheme.border,
        // enabledBorder: inputTheme.enabledBorder,
        // focusedBorder: inputTheme.focusedBorder,
        // errorBorder: inputTheme.errorBorder,
        // focusedErrorBorder: inputTheme.focusedErrorBorder,

        // Other decoration properties
        labelText: labelText,
        prefixIcon: IconTheme(
          data: IconThemeData(
            color: dark ? TColors.yellow : TColors.primary,
          ),
          child: prefixIcon,
        ),
        suffixIcon: suffixIcon != null
            ? IconTheme(
                data: IconThemeData(color: iconColor),
                child: suffixIcon!,
              )
            : null,
      ),
    );
  }
}
