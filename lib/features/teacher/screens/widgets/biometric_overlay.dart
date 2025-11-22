import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../../../common/utils/constants/sized.dart';
import '../../controllers/dashboard_controller.dart';

class BiometricOverlay extends StatelessWidget {
  const BiometricOverlay({
    super.key,
    required this.dashboardController,
    required this.dark,
  });

  final DashboardController dashboardController;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                dashboardController.biometricAuthService.availableBiometrics
                        .contains(BiometricType.face)
                    ? Icons.fingerprint_outlined
                    : Icons.fingerprint,
                size: 64,
                color: dark ? TColors.yellow : TColors.primary,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(
                'Authenticate to access',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ElevatedButton.icon(
                onPressed: () async {
                  await dashboardController.authenticateWithBiometrics();
                },
                icon: Icon(
                  dashboardController.biometricAuthService.availableBiometrics
                          .contains(BiometricType.face)
                      ? Icons.fingerprint_outlined
                      : Icons.fingerprint,
                  color: dark ? TColors.dark : Colors.white,
                ),
                label: Text(
                  'Authenticate with ${dashboardController.biometricAuthService.getBiometricTypeString()}',
                  style: TextStyle(
                    color: dark ? TColors.dark : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? TColors.yellow : TColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.defaultSpace,
                    vertical: TSizes.md,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              TextButton(
                onPressed: () {
                  // Skip authentication for this session
                  dashboardController.isAuthenticated.value = true;
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: dark ? TColors.yellow : TColors.primary,
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
