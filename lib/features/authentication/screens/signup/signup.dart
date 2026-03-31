import 'package:flutter/material.dart';

import '../../../../common/utils/constants/colors.dart';
import '../../../../common/utils/constants/sized.dart';
import '../../../../common/utils/constants/text_strings.dart';
import 'singup_widgets/signup_form.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.spaceBtwSections),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                TTexts.createAccount.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Signup Form
              SignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}
