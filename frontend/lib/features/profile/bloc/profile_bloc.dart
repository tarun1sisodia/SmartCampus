import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  const UpdateProfile(this.payload);
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [payload];
}

class UploadPhoto extends ProfileEvent {
  const UploadPhoto(this.file);
  final File file;

  @override
  List<Object?> get props => [file.path];
}

class ChangePassword extends ProfileEvent {
  const ChangePassword(this.oldPassword, this.newPassword);
  final String oldPassword;
  final String newPassword;

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);
  final ProfileModel profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess(this.profile, this.message);
  final ProfileModel profile;
  final String message;

  @override
  List<Object?> get props => [profile, message];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadPhoto>(_onUploadPhoto);
    on<ChangePassword>(_onChangePassword);
  }

  final ProfileRepository _repository;
  ProfileModel? _current;

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      _current = await _repository.fetchProfile();
      emit(ProfileLoaded(_current!));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    try {
      final profile = await _repository.updateProfile(event.payload);
      _current = profile;
      emit(ProfileUpdateSuccess(profile, 'Profile updated successfully'));
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
      if (_current != null) emit(ProfileLoaded(_current!));
    }
  }

  Future<void> _onUploadPhoto(UploadPhoto event, Emitter<ProfileState> emit) async {
    try {
      final profile = await _repository.uploadPhoto(event.file);
      _current = profile;
      emit(ProfileUpdateSuccess(profile, 'Profile photo updated successfully'));
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
      if (_current != null) emit(ProfileLoaded(_current!));
    }
  }

  Future<void> _onChangePassword(ChangePassword event, Emitter<ProfileState> emit) async {
    try {
      await _repository.changePassword(event.oldPassword, event.newPassword);
      if (_current != null) {
        emit(ProfileUpdateSuccess(_current!, 'Password changed successfully'));
        emit(ProfileLoaded(_current!));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
      if (_current != null) emit(ProfileLoaded(_current!));
    }
  }
}
