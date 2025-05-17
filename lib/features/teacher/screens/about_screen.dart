import 'package:attedance__/common/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import 'package:url_launcher/url_launcher.dart';

import 'legal_screen.dart';

class _AnimatedBorderPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;

  _AnimatedBorderPainter({required this.progress, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final radius = size.height / 2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final totalLength =
        path.computeMetrics().fold(0.0, (double prev, m) => prev + m.length);
    final currentLength = totalLength * progress;

    double drawnLength = 0.0;
    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      final draw = (drawnLength + length <= currentLength)
          ? length
          : (currentLength - drawnLength).clamp(0.0, length);
      if (draw > 0) {
        final extractPath = metric.extractPath(0, draw);
        canvas.drawPath(extractPath, paint);
      }
      drawnLength += length;
      if (drawnLength >= currentLength) break;
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.gradient != gradient;
  }
}

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
                  color: dark ? TColors.yellow : TColors.purple,
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage(
                    TImageStrings.appLogo,
                  ),
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
              'Version 0.0.1',
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
              'The Attendance Management System is a cross-platform Flutter application designed to simplify and streamline the process of tracking student attendance in educational institutions. It provides teachers with tools to manage classes, record attendance, and analyze attendance data efficiently.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.start,
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
            // Animated border and content reveal
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                // Animation split: 0.0-0.7 for border, 0.7-1.0 for content fade
                final borderProgress = value < 0.7 ? value / 0.7 : 1.0;
                final contentProgress =
                    value < 0.7 ? 0.0 : ((value - 0.7) / 0.3).clamp(0.0, 1.0);

                return CustomPaint(
                  painter: _AnimatedBorderPainter(
                    progress: borderProgress,
                    gradient: LinearGradient(
                      colors: [
                        TColors.primary,
                        TColors.yellow,
                        TColors.purple,
                        TColors.primary,
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // ListTile content with fade and slide from icon to right
                      Opacity(
                        opacity: contentProgress,
                        child: FractionalTranslation(
                          translation: Offset(1 - contentProgress, 0),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(TSizes.sm),
                              decoration: BoxDecoration(
                                color: (dark ? TColors.yellow : TColors.primary)
                                    .withAlpha(26),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.code,
                                color: dark ? TColors.yellow : TColors.primary,
                              ),
                            ),
                            title: const Text('Tarun Sisodia'),
                            subtitle: const Text('Lead Developer'),
                          ),
                        ),
                      ),
                      // Show only the icon during border animation
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color:
                      (dark ? TColors.yellow : TColors.primary).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  TImageStrings.google,
                  height: 100,
                  width: 20,
                ),
              ),
              title: const Text('Google Developer'),
              subtitle: const Text('g.dev/tarun1sisodia'),
              onTap: () async {
                const url = 'https://g.dev/tarun1sisodia';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }

                // Custom painter for animated border
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  TImageStrings.github,
                  height: 100,
                  width: 20,
                ),
              ),
              title: const Text('GitHub'),
              subtitle: const Text('github.com/tarun1sisodia/tarun1sisodia'),
              onTap: () async {
                const url = 'https://github.com/tarun1sisodia/tarun1sisodia';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  TImageStrings.instagram,
                  height: 100,
                  width: 20,
                ),
              ),
              title: const Text('Instagram'),
              subtitle: const Text('instagram.com/tarun1sisodia'),
              onTap: () async {
                const url = 'https://instagram.com/tarun1sisodia';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  dark
                      ? TImageStrings.linkedinLight
                      : TImageStrings.linkedinDark,
                  height: 100,
                  width: 20,
                ),
              ),
              title: const Text('LinkedIn'),
              subtitle: const Text('linkedin.com/in/tarun1sisodia'),
              onTap: () async {
                const url = 'https://linkedin.com/in/tarun1sisodia';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  TImageStrings.twitter,
                  height: 100,
                  width: 20,
                ),
              ),
              title: const Text('X (Twitter)'),
              subtitle: const Text('x.com/tarun1sisodia'),
              onTap: () async {
                const url = 'https://x.com/tarun1sisodia';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalScreen(
                      initialSection: 'privacy_policy',
                    ),
                  ),
                );
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: dark ? TColors.yellow : TColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalScreen(
                      initialSection: 'terms_of_service',
                    ),
                  ),
                );
              },
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: dark ? TColors.yellow : TColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalScreen(
                      initialSection: 'open_source_licenses',
                    ),
                  ),
                );
              },
              child: Text(
                'Open Source Licenses',
                style: TextStyle(
                  color: dark ? TColors.yellow : TColors.primary,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Copyright
            Text(
              '© 2025 Attendance App. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
