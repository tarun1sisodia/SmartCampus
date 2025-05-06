import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        children: [
          // Help categories
          _buildHelpCategory(
            context,
            title: 'Frequently Asked Questions',
            icon: Iconsax.message_question,
            color: Colors.blue,
            onTap: () {
              // Show FAQs
              _showFAQs(context);
            },
          ),

          _buildHelpCategory(
            context,
            title: 'Contact Support',
            icon: Iconsax.message,
            color: Colors.green,
            onTap: () {
              // Show contact options
              _showContactOptions(context);
            },
          ),

          _buildHelpCategory(
            context,
            title: 'User Guide',
            icon: Iconsax.book_1,
            color: Colors.orange,
            onTap: () {
              // Show user guide
            },
          ),

          _buildHelpCategory(
            context,
            title: 'Video Tutorials',
            icon: Iconsax.video,
            color: Colors.red,
            onTap: () {
              // Show video tutorials
            },
          ),

          const SizedBox(height: TSizes.spaceBtwSections),

          // Common issues section
          Text(
            'Common Issues',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          _buildFAQItem(
            context,
            question: 'How do I mark attendance?',
            answer:
                'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there, you can create a new session and mark students as present, absent, or late.',
          ),

          _buildFAQItem(
            context,
            question: 'How do I add a new student?',
            answer:
                'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there, you can tap the "+" button to add a new student to the class.',
          ),

          _buildFAQItem(
            context,
            question: 'How do I generate reports?',
            answer:
                'To generate reports, go to the More tab, select "Reports". From there, you can choose the type of report you want to generate and export it in your preferred format.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCategory(
    BuildContext context, {
    required String title,
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
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: dark ? TColors.yellow : TColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  void _showFAQs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            children: [
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              _buildFAQItem(
                context,
                question: 'How do I mark attendance?',
                answer:
                    'To mark attendance, go to the Classes tab, select a class, then tap on "Attendance". From there, you can create a new session and mark students as present, absent, or late.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I add a new student?',
                answer:
                    'To add a new student, go to the Classes tab, select a class, then tap on "Students". From there, you can tap the "+" button to add a new student to the class.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I generate reports?',
                answer:
                    'To generate reports, go to the More tab, select "Reports". From there, you can choose the type of report you want to generate and export it in your preferred format.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I create a new class?',
                answer:
                    'To create a new class, go to the Classes tab and tap the "+" button in the bottom right corner. Fill in the class details and tap "Create".',
              ),
              _buildFAQItem(
                context,
                question: 'How do I edit a student\'s information?',
                answer:
                    'To edit a student\'s information, go to the Classes tab, select a class, then tap on "Students". Find the student you want to edit, tap on their name, and then tap the edit button.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I view attendance history?',
                answer:
                    'To view attendance history, go to the Classes tab, select a class, then tap on "Attendance". You will see a list of all attendance sessions for that class.',
              ),
            ],
          );
        },
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Support',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.message, color: Colors.blue),
              ),
              title: const Text('Email Support'),
              subtitle: const Text('support@attendanceapp.com'),
              onTap: () {
                // Launch email app
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.call, color: Colors.green),
              ),
              title: const Text('Phone Support'),
              subtitle: const Text('+1 (123) 456-7890'),
              onTap: () {
                // Launch phone app
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.global, color: Colors.purple),
              ),
              title: const Text('Visit Website'),
              subtitle: const Text('www.attendanceapp.com/support'),
              onTap: () {
                // Launch website
              },
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? TColors.yellow : TColors.primary,
                  foregroundColor: dark ? TColors.dark : Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
