import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfileModel> fetchProfile() async {
    final response = await _apiClient.dio.get(Endpoints.me);
    final data = response.data['data'] ?? response.data['user'] ?? response.data;
    return ProfileModel.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> payload) async {
    final response = await _apiClient.dio.patch(Endpoints.me, data: payload);
    final data = response.data['data'] ?? response.data['user'] ?? response.data;
    return ProfileModel.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<ProfileModel> uploadPhoto(File file) async {
    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });
    final response = await _apiClient.dio.post(Endpoints.uploadProfilePhoto, data: form);
    final data = response.data['data'] ?? response.data['user'] ?? response.data;
    return ProfileModel.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiClient.dio.post(
      Endpoints.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }
}
