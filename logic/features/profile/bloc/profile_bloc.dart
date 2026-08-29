// =============================================================
// profile_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/profile/bloc/profile_bloc.dart)
// Events + states + bloc (definitions live in this file).
// =============================================================

// EVENTS: LoadProfile | UpdateProfile(payload) | UploadPhoto(file) | ChangePassword(old, new)

// STATES: ProfileInitial | ProfileLoading | ProfileLoaded(profile) |
//         ProfileUpdateSuccess(profile, message) | ProfileError(message)

// class ProfileBloc(ProfileRepository) :
//   keeps _current profile so the screen can fall back to it when an action fails

// _onLoadProfile : emit loading -> fetch -> emit Loaded ; error -> Error
// _onUpdateProfile :
//   repo.updateProfile(payload) -> save as _current -> emit UpdateSuccess -> emit Loaded
//   error -> emit Error then re-emit Loaded(_current) (screen goes back to last good state)
// _onUploadPhoto : same pattern with repo.uploadPhoto(file)
// _onChangePassword :
//   repo.changePassword(old,new) -> emit UpdateSuccess('password changed') -> emit Loaded
//   error -> emit Error + restore Loaded(_current)
