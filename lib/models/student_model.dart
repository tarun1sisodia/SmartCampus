class StudentModel {
  final String id;
  final String name;
  final String rollNumber;
  final String classId;
  final String? imageUrl; // Add this field
  final DateTime? createdAt;
  final DateTime? updatedAt;
  String? attendanceStatus; // For tracking attendance in UI

  StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.classId,
    this.imageUrl, // Add this parameter
    this.createdAt,
    this.updatedAt,
    this.attendanceStatus,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      rollNumber: json['roll_number'],
      classId: json['class_id'],
      imageUrl: json['image_url'], // Add this field
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
      'class_id': classId,
      'image_url': imageUrl, // Add this field
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
