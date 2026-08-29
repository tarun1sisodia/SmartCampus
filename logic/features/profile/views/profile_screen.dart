// =============================================================
// profile_screen.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/profile/views/profile_screen.dart)
// =============================================================

// class ProfileScreen (StatefulWidget) :
//   controllers: name, contact, old password, new password

// initState :
//   dispatch LoadProfile; prefill fields when profile arrives
//   _biometricEnabled = Hive settings_box 'biometric_enabled' == true

// build :
//   BlocProvider ProfileBloc
//   BlocListener -> on UpdateSuccess/Error show snackbar
//   UI sections:
//     avatar + camera button -> _pickAndUploadPhoto
//     edit name/contact + SAVE -> dispatch UpdateProfile({name, contact})
//     biometric toggle -> _toggleBiometric
//     change password form -> dispatch ChangePassword(old, new)
//     dark mode toggle -> dispatch SettingsBloc UpdateThemeMode
//     LOGOUT button -> dispatch LogoutRequested

// _pickAndUploadPhoto(context) :
//   ImagePicker.pickImage (gallery) -> if picked -> dispatch UploadPhoto(File)

// _toggleBiometric(context, value) :
//   if enabling -> run BiometricService.authenticate(); only save on success
//   store 'biometric_enabled' in Hive settings box
