import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/common/utils/constants/text_strings.dart';
import 'package:smart_campus/features/authentication/screens/login/login.dart';

class EmailSuccess extends StatelessWidget {
  const EmailSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => Get.offAll(() => Login()),
            icon: const Icon(Iconsax.close_circle, color: TColors.slate900, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Indicator
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: TColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF10B981), width: 3.0),
                ),
                child: const Icon(Iconsax.tick_circle, size: 100, color: Color(0xFF10B981)),
              ),
              
              const SizedBox(height: 48),
              
              Text(
                TTexts.registrationSuccess.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1.0, color: TColors.slate900),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                TTexts.emailVerified.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: TColors.slate600, letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 64),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => Login()),
                  child: Text(
                    TTexts.continueText.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
