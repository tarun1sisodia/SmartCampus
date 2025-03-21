class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final List<String> classIds; // References to classes taught by the teacher

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.classIds,
  });
  
  // Getter for uid (to match Firebase auth user structure)
  String get uid => id;

  // Factory constructor to create a UserModel from a Map (Firestore document)
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'teacher', // Default role is teacher
      photoUrl: map['photoUrl'],
      classIds: List<String>.from(map['classIds'] ?? []),
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'classIds': classIds,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? photoUrl,
    List<String>? classIds,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      classIds: classIds ?? this.classIds,
    );
  }
}