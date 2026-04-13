import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePhoto;
  final String role;
  final String? organizationId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    required this.role,
    this.organizationId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePhoto: json['profilePhoto'] ?? json['avatarUrl'],
      role: json['role'] ?? 'teacher',
      organizationId: json['organizationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePhoto': profilePhoto,
      'role': role,
      'organizationId': organizationId,
    };
  }

  @override
  List<Object?> get props => [id, name, email, profilePhoto, role, organizationId];
}
