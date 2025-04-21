import 'package:attedance__/features/authentication/controllers/supabase_auth_controller.dart';
import 'package:attedance__/features/authentication/screens/login/login.dart';
import 'package:attedance__/features/authentication/screens/signup/singup_widgets/email_success.dart';
import 'package:attedance__/common/utils/constants/image_strings.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/constants/text_strings.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';


class VerifyEmailScreen extends StatelessWidget {
  final String email;
  
  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupabaseAuthController>();
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.offAll(() => Login()),
            icon: Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Image(
                image: AssetImage(TImageStrings.verifyemail),
                width: THelperFunction.screenWidth() * 0.6,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                TTexts.confirmEmail,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                email,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                TTexts.verifyEmailSubtitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Continue button
              SizedBox(
                height: TSizes.appBarHeight,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Check if email is verified
                      final isVerified = await controller.checkEmailVerified();
                      
                      if (isVerified) {
                        // Email is verified, now store the user data
                        await controller.storeUserData();
                        Get.to(() => EmailSuccess());
                      } else {
                        // Try to sign in to refresh the session
                        try {
                          await controller.signInWithEmail();
                          
                          // If sign-in succeeds, email is verified
                          await controller.storeUserData();
                          Get.to(() => EmailSuccess());
                        } catch (e) {
                          Get.snackbar(
                            'Verification Pending',
                            'Please verify your email by clicking the link we sent you',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Could not verify email status',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: email,
                        );
                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Could not launch email app',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to open email app: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: Text(
                      TTexts.continueText,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              // Resend email button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    try {
                      // Resend verification email
                      await controller.resendVerificationEmail(email);
                      Get.snackbar(
                        'Email Sent',
                        'Verification email has been resent',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to resend verification email',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text(
                    TTexts.resendEmail,
                    style: Theme.of(context).textTheme.labelSmall,
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
