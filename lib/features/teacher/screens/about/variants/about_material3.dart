import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutMaterial3 extends StatelessWidget {
  const AboutMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildM3Header(theme),
          const SizedBox(height: 32),
          _buildM3IdentityCard(theme),
          const SizedBox(height: 24),
          _buildM3Section(theme, 'Mission Statement', [
            Text('The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
          ]),
          const SizedBox(height: 24),
          _buildM3Section(theme, 'Developer Uplink', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Icon(Iconsax.code, color: theme.colorScheme.onPrimaryContainer, size: 20)),
              title: const Text('Tarun Sisodia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: const Text('Lead Architect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 24),
            Text('Connected Nodes', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildM3SocialGrid(theme),
          ]),
          const SizedBox(height: 64),
          Center(child: Text('© 2025 SmartCampus Institutional', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Application context and identity.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3IdentityCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary, width: 2), image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover))),
            const SizedBox(height: 24),
            Text('Smart Campus', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('Institutional Build v0.0.1', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildM3Section(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildM3SocialGrid(ThemeData theme) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: [
        _m3SocialChip(theme, 'G_DEV', 'https://g.dev/tarun1sisodia'),
        _m3SocialChip(theme, 'GITHUB', 'https://github.com/tarun1sisodia'),
        _m3SocialChip(theme, 'LINKEDIN', 'https://linkedin.com/in/tarun1sisodia'),
        _m3SocialChip(theme, 'X_CORE', 'https://x.com/tarun1sisodia'),
      ],
    );
  }

  Widget _m3SocialChip(ThemeData theme, String label, String url) {
    return ActionChip(
      onPressed: () async => await launchUrl(Uri.parse(url)),
      label: Text(label),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      side: BorderSide.none,
    );
  }
}
