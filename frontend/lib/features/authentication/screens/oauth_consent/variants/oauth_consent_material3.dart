import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/oauth_consent_controller.dart';

class OAuthConsentMaterial3 extends StatelessWidget {
  const OAuthConsentMaterial3({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OAuthConsentController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              _buildM3Header(theme),
              const SizedBox(height: 56),
              _buildM3ConsentCard(appName, scopes, theme),
              const SizedBox(height: 48),
              _buildM3Actions(controller, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(32)),
          child: Icon(Iconsax.security_user, color: theme.colorScheme.primary, size: 48),
        ),
        const SizedBox(height: 32),
        Text('App Authorization', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -1)),
        const SizedBox(height: 12),
        Text('A third-party application is requesting access.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3ConsentCard(String appName, List<String> scopes, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(appName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 32),
          Text('Requests access to:', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          ...scopes.map((scope) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 12),
                Text(scope, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildM3Actions(OAuthConsentController controller, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => controller.grantConsent(),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Allow Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => controller.denyConsent(),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Deny & Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
