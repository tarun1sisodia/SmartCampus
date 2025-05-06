import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class ImportDataScreen extends StatelessWidget {
  const ImportDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Import Data',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Options',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Import format selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Format',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Obx(
                      () => Row(
                        children: [
                          _buildFormatOption(
                            context,
                            format: 'Excel',
                            icon: Iconsax.document_text,
                            color: Colors.green,
                            isSelected: selectedFileType.value == 'Excel',
                            onTap: () => selectedFileType.value = 'Excel',
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          _buildFormatOption(
                            context,
                            format: 'CSV',
                            icon: Iconsax.document_text_1,
                            color: Colors.blue,
                            isSelected: selectedFileType.value == 'CSV',
                            onTap: () => selectedFileType.value = 'CSV',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // File selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select File',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Obx(
                      () => fileSelected.value
                          ? Container(
                              padding: const EdgeInsets.all(TSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  TSizes.borderRadiusMd,
                                ),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selectedFileType.value == 'Excel'
                                        ? Iconsax.document_text
                                        : Iconsax.document_text_1,
                                    color: selectedFileType.value == 'Excel'
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                  const SizedBox(width: TSizes.spaceBtwItems),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName.value,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Ready to import',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Iconsax.close_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      fileSelected.value = false;
                                      fileName.value = '';
                                    },
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                // Simulate file selection
                                fileSelected.value = true;
                                fileName.value =
                                    'student_data.${selectedFileType.value.toLowerCase()}';
                              },
                              borderRadius: BorderRadius.circular(
                                TSizes.borderRadiusMd,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(TSizes.lg),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    TSizes.borderRadiusMd,
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Iconsax.import,
                                      size: 48,
                                      color: dark
                                          ? TColors.yellow
                                          : TColors.primary,
                                    ),
                                    const SizedBox(
                                      height: TSizes.spaceBtwItems,
                                    ),
                                    Text(
                                      'Click to select a file',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: TSizes.xs),
                                    Text(
                                      'Supported formats: ${selectedFileType.value}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Import options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    CheckboxListTile(
                      title: const Text('Replace existing data'),
                      subtitle: const Text(
                        'Warning: This will overwrite any existing data',
                      ),
                      value: false,
                      onChanged: (value) {
                        // Toggle replace option
                      },
                      activeColor: dark ? TColors.yellow : TColors.primary,
                    ),
                    CheckboxListTile(
                      title: const Text('Skip header row'),
                      subtitle: const Text(
                        'If your file contains column headers',
                      ),
                      value: true,
                      onChanged: (value) {
                        // Toggle skip header option
                      },
                      activeColor: dark ? TColors.yellow : TColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Import button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: (!fileSelected.value || isImporting.value)
                      ? null
                      : () {
                          // Start import
                          isImporting.value = true;

                          // Simulate import process
                          Future.delayed(const Duration(seconds: 2), () {
                            isImporting.value = false;
                            TSnackBar.showSuccess(
                              message: 'Data imported successfully',
                            );
                            Get.back();
                          });
                        },
                  icon: isImporting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.import),
                  label: Text(
                    isImporting.value ? 'Importing...' : 'Import Data',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.primary,
                    foregroundColor: dark ? TColors.dark : Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context, {
    required String format,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: TSizes.md,
            horizontal: TSizes.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: TSizes.xs),
              Text(
                format,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
