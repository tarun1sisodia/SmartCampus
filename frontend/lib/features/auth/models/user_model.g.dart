// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      role: json['role'] as String,
      organizationId: json['organizationId'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profilePhoto': instance.profilePhoto,
      'role': instance.role,
      'organizationId': instance.organizationId,
    };
