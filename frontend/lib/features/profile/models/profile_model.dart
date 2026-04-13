import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.contact,
    this.photoUrl,
    this.language,
  });

  final String id;
  final String name;
  final String email;
  final String? contact;
  final String? photoUrl;
  final String? language;

  ProfileModel copyWith({
    String? name,
    String? email,
    String? contact,
    String? photoUrl,
    String? language,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      contact: json['contact']?.toString(),
      photoUrl: (json['photoUrl'] ?? json['avatarUrl'])?.toString(),
      language: json['language']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name, email, contact, photoUrl, language];
}
