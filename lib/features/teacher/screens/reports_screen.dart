import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sized.dart';
import '../../../utils/helpers/helper_function.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        children: [
          // Report types section
          _buildSectionHeader(context, 'Report Types'),
          
          // Attendance summary card
          _buildReportCard(
            context,
            title: 'Attendance Summary',
            description: 'View overall attendance statistics',
            icon: Iconsax.chart_2,
            color: Colors.blue,
            onTap: () {
              // Navigate to attendance summary report
              Get.toNamed('/attendance-reports');
            },
          ),
          
          // Student performance card
          _buildReportCard(
            context,
            title: 'Student Performance',
            description: 'Analyze individual student attendance',
            icon: Iconsax.user_octagon,
            color: Colors.green,
            onTap: () {
              // Navigate to student performance report
            },
          ),
          
          // Class comparison card
          _buildReportCard(
            context,
            title: 'Class Comparison',
            description: 'Compare attendance across different classes',
            icon: Iconsax.component,
            color: Colors.purple,
            onTap: () {
              // Navigate to class comparison report
            },
          ),
          
          const SizedBox(height: TSizes.spaceBtwSections),
          
          // Export options section
          _buildSectionHeader(context, 'Export Options'),
          
          // PDF export card
          _buildReportCard(
            context,
            title: 'Export as PDF',
            description: 'Generate and download PDF reports',
            icon: Iconsax.document_1,
            color: Colors.red,
            onTap: () {
              // Show PDF export options
            },
          ),
          
          // Excel export card
          _buildReportCard(
            context,
            title: 'Export as Excel',
            description: 'Generate and download Excel spreadsheets',
            icon: Iconsax.document_text,
            color: Colors.teal,
            onTap: () {
              // Show Excel export options
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final dark = THelperFunction.isDarkMode(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: TSizes.xs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: dark ? TColors.yellow : TColors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
