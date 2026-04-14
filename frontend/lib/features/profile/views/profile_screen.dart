import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/cache/hive_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../shared/widgets/custom_button.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String _language = 'en';
  bool _biometricEnabled = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    final settingsState = getIt<SettingsBloc>().state;
    _language = settingsState.locale.languageCode;
    _darkMode = settingsState.themeMode == ThemeMode.dark;
    _biometricEnabled =
        getIt<HiveService>().settingsBox.get('biometric_enabled') == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body:
            BlocConsumer<ProfileBloc, ProfileState>(listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        }, builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! ProfileLoaded) {
            return const Center(child: Text('Failed to load profile'));
          }

          final profile = state.profile;
          _nameController.text = profile.name;
          _contactController.text = profile.contact ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profile.photoUrl == null
                            ? null
                            : NetworkImage(profile.photoUrl!),
                        child: profile.photoUrl == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _pickAndUploadPhoto(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      labelText: 'Email', hintText: profile.email),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'UPDATE PROFILE',
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                          UpdateProfile({
                            'name': _nameController.text.trim(),
                            'contact': _contactController.text.trim(),
                            'language': _language,
                          }),
                        );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Change Password',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                          ChangePassword(
                            _oldPasswordController.text,
                            _newPasswordController.text,
                          ),
                        );
                  },
                  child: const Text('CHANGE PASSWORD'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() => _darkMode = value);
                    context.read<SettingsBloc>().add(
                          UpdateThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light),
                        );
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _language,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _language = value);
                    context
                        .read<SettingsBloc>()
                        .add(UpdateLocale(Locale(value)));
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Enable Biometric'),
                  value: _biometricEnabled,
                  onChanged: (value) => _toggleBiometric(context, value),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'LOGOUT',
                  color: Colors.red,
                  onPressed: () =>
                      context.read<AuthBloc>().add(LogoutRequested()),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    context.read<ProfileBloc>().add(UploadPhoto(File(picked.path)));
  }

  Future<void> _toggleBiometric(BuildContext context, bool value) async {
    if (value) {
      final service = getIt<BiometricService>();
      final available = await service.isBiometricAvailable();
      if (!available) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Biometric authentication is not available')),
          );
        }
        return;
      }
    }
    setState(() => _biometricEnabled = value);
    await getIt<HiveService>().settingsBox.put('biometric_enabled', value);
  }
}
