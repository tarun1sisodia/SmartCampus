import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../../../common/utils/constants/sized.dart';
import '../../controllers/oauth_consent_controller.dart';

class OAuthConsentScreen extends StatelessWidget {
  const OAuthConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OAuthConsentController());
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Authorization Request'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: TColors.primary),
          );
        }

        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, color: TColors.error, size: 60),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    controller.error.value!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Go Back'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final details = controller.authDetails.value!;
        final client = details['client'] as Map<String, dynamic>;
        final scopes = details['scopes'] as List<dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Client Logo / Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: TColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.security_user,
                    size: 50, color: TColors.primary),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Title
              Text(
                'Authorize ${client['name']}',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.sm),
              Text(
                'This application is requesting access to your SmartCampus account.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: TColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Scopes List
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'THE APPLICATION WILL BE ABLE TO:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scopes.length,
                separatorBuilder: (_, __) => const SizedBox(height: TSizes.sm),
                itemBuilder: (context, index) {
                  final scope = scopes[index];
                  return Container(
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      color: isDark ? TColors.dark54 : TColors.white,
                      borderRadius:
                          BorderRadius.circular(TSizes.borderRadiusMd),
                      border: Border.all(
                          color: TColors.borderPrimary.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.tick_circle5,
                            color: TColors.success, size: 20),
                        const SizedBox(width: TSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scope['name'] ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                scope['description'] ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Authentication Disclaimer
              Text(
                'Make sure you trust this application before authorizing.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.deny(),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: TSizes.md),
                        side: const BorderSide(color: TColors.textSecondary),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: TColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: TSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.approve(),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: TSizes.md),
                        backgroundColor: TColors.primary,
                      ),
                      child: const Text('Authorize'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        );
      }),
    );
  }
}
