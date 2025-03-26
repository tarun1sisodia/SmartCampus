import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sized.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/snackbar_helper.dart';

class ExportDataScreen extends StatelessWidget {
  const ExportDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final RxBool isExporting = false.obs;
    final RxString selectedFormat = 'PDF'.obs;
    final RxBool includeStudentDetails = true.obs;
    final RxBool includeAttendanceHistory = true.obs;
    final RxBool includeClassStats = true.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export Data',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            // Export format selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Format',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Obx(() => Row(
                      children: [
                        _buildFormatOption(
                          context,
                          format: 'PDF',
                          icon: Iconsax.document_1,
                          color: Colors.red,
                          isSelected: selectedFormat.value == 'PDF',
                          onTap: () => selectedFormat.value = 'PDF',
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        _buildFormatOption(
                          context,
                          format: 'Excel',
                          icon: Iconsax.document_text,
                          color: Colors.green,
                          isSelected: selectedFormat.value == 'Excel',
                          onTap: () => selectedFormat.value = 'Excel',
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        _buildFormatOption(
                          context,
                          format: 'CSV',
                          icon: Iconsax.document_text_1,
                          color: Colors.blue,
                          isSelected: selectedFormat.value == 'CSV',
                          onTap: () => selectedFormat.value = 'CSV',
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: TSizes.spaceBtwItems),
            
            // Data selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data to Include',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Obx(() => CheckboxListTile(
                      title: const Text('Student Details'),
                      subtitle: const Text('Names, roll numbers, and contact info'),
                      value: includeStudentDetails.value,
                      onChanged: (value) => includeStudentDetails.value = value ?? true,
                      activeColor: dark ? TColors.yellow : TColors.deepPurple,
                    )),
                    Obx(() => CheckboxListTile(
                      title: const Text('Attendance History'),
                      subtitle: const Text('Complete attendance records for all sessions'),
                      value: includeAttendanceHistory.value,
                      onChanged: (value) => includeAttendanceHistory.value = value ?? true,
                      activeColor: dark ? TColors.yellow : TColors.deepPurple,
                    )),
                    Obx(() => CheckboxListTile(
                      title: const Text('Class Statistics'),
                      subtitle: const Text('Attendance percentages and summary data'),
                      value: includeClassStats.value,
                      onChanged: (value) => includeClassStats.value = value ?? true,
                      activeColor: dark ? TColors.yellow : TColors.deepPurple,
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: TSizes.spaceBtwItems),
            
            // Date range selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                              ),
                              suffixIcon: const Icon(Iconsax.calendar),
                            ),
                            readOnly: true,
                            onTap: () async {
                              // Show date picker
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 30)),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              
                              if (pickedDate != null) {
                                // Update start date
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                              ),
                              suffixIcon: const Icon(Iconsax.calendar),
                            ),
                            readOnly: true,
                            onTap: () async {
                              // Show date picker
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              
                              if (pickedDate != null) {
                                // Update end date
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: TSizes.spaceBtwSections),
            
            // Export button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton.icon(
                onPressed: isExporting.value
                    ? null
                    : () {
                        // Validate and export
                        if (!includeStudentDetails.value && 
                            !includeAttendanceHistory.value && 
                            !includeClassStats.value) {
                          TSnackBar.showError(
                            message: 'Please select at least one data type to include',
                          );
                          return;
                        }
                        
                        // Start export
                        isExporting.value = true;
                        
                        // Simulate export process
                        Future.delayed(const Duration(seconds: 2), () {
                          isExporting.value = false;
                          TSnackBar.showSuccess(
                            message: 'Data exported successfully as ${selectedFormat.value}',
                          );
                        });
                      },
                icon: isExporting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Iconsax.export),
                label: Text(isExporting.value ? 'Exporting...' : 'Export Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                  foregroundColor: dark ? Colors.black : Colors.white,
                ),
              )),
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
