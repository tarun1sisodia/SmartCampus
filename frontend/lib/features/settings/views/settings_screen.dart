import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../mixins/ui_feedback_mixin.dart';
import '../../hive/views/hive_inspector_screen.dart';

class SettingsScreen extends StatelessWidget with UIFeedbackMixin {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SETTINGS'),
            centerTitle: true,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, 'Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark themes'),
                secondary: Icon(state.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    UpdateThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                  );
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Account'),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                   showSnackBar(context, 'Change password coming soon...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () => _showLogoutConfirm(context),
              ),
              const Divider(),
              _buildSectionHeader(context, 'Developer & Debug'),
              ListTile(
                leading: const Icon(Icons.storage_rounded),
                title: const Text('Hive Inspector'),
                subtitle: const Text('Manage local data cache'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HiveInspectorScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'v1.0.0+1',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to sign out of SmartCampus?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context);
            },
            child: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
