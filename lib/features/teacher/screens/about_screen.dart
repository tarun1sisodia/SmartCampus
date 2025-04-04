import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? TColors.yellow : TColors.deepPurple,
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/logos/smartcampus.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // App name and version
            Text(
              'Smart Campus',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.xs),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // App description
            Text(
              'About the App',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'Attendance App is a comprehensive solution for teachers to manage class attendance efficiently. With features like real-time attendance tracking, detailed reports, and student management, it simplifies the administrative tasks for educators.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Developer info
            Text(
              'Developer',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: (dark ? TColors.yellow : TColors.deepPurple)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.code,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
              ),
              title: const Text('Tarun Sisodia'),
              subtitle: const Text('Lead Developer'),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Contact info
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: (dark ? TColors.yellow : TColors.deepPurple)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.global,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
              ),
              title: const Text('Website'),
              subtitle: const Text('www.attendanceapp.com'),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: (dark ? TColors.yellow : TColors.deepPurple)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.message,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
              ),
              title: const Text('Google Developer'),
              subtitle: const Text('g.dev/tarun1sisodia'),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Legal info
            Text(
              'Legal',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextButton(
              onPressed: () {
                // Show privacy policy
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Show terms of service
              },
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Show licenses
              },
              child: Text(
                'Open Source Licenses',
                style: TextStyle(
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Copyright
            Text(
              '© 2023 Attendance App. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
