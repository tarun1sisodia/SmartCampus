import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePhoto;
  final String role;
  @JsonKey(name: 'organizationId')
  final String? organizationId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    required this.role,
    this.organizationId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(
        _normalizeJson(json),
      );

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'profilePhoto': json['profilePhoto'] ?? json['avatarUrl'],
      'organizationId': json['organizationId'] ?? json['organisation']?.toString(),
      'role': json['role'] ?? 'teacher',
    };
  }

  @override
  List<Object?> get props => [id, name, email, profilePhoto, role, organizationId];
}
