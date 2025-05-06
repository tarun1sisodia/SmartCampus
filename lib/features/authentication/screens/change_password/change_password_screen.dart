import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../../../common/utils/constants/sized.dart';
import '../../../../common/utils/helpers/helper_function.dart';
import '../../controllers/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  final controller = Get.put(ChangePasswordController());

  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Update Your Password',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              'Enter your current password and a new password to update your credentials',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Current Password Field
            Obx(
              () => TextFormField(
                controller: controller.currentPasswordController,
                obscureText: !controller.isCurrentPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: controller.toggleCurrentPasswordVisibility,
                    icon: Icon(
                      controller.isCurrentPasswordVisible.value
                          ? Iconsax.eye
                          : Iconsax.eye_slash,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      TSizes.inputFieldRadius,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // New Password Field
            Obx(
              () => TextFormField(
                controller: controller.newPasswordController,
                obscureText: !controller.isNewPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Iconsax.lock),
                  suffixIcon: IconButton(
                    onPressed: controller.toggleNewPasswordVisibility,
                    icon: Icon(
                      controller.isNewPasswordVisible.value
                          ? Iconsax.eye
                          : Iconsax.eye_slash,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      TSizes.inputFieldRadius,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Confirm Password Field
            Obx(
              () => TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: !controller.isConfirmPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Iconsax.lock),
                  suffixIcon: IconButton(
                    onPressed: controller.toggleConfirmPasswordVisibility,
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Iconsax.eye
                          : Iconsax.eye_slash,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      TSizes.inputFieldRadius,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Password Requirements
            Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: dark ? TColors.darkerGrey : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Requirements:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  _buildRequirementItem(
                    context,
                    'At least 8 characters long',
                    Iconsax.tick_circle,
                    dark ? TColors.yellow : TColors.primary,
                  ),
                  _buildRequirementItem(
                    context,
                    'Contains uppercase and lowercase letters',
                    Iconsax.tick_circle,
                    dark ? TColors.yellow : TColors.primary,
                  ),
                  _buildRequirementItem(
                    context,
                    'Contains at least one number',
                    Iconsax.tick_circle,
                    dark ? TColors.yellow : TColors.primary,
                  ),
                  _buildRequirementItem(
                    context,
                    'Contains at least one special character',
                    Iconsax.tick_circle,
                    dark ? TColors.yellow : TColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.primary,
                    foregroundColor: dark ? TColors.dark : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: TSizes.buttonHeight,
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Change Password'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.sm),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: TSizes.sm),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
