class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String course;
  final int year;
  final String? imageUrl;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.course,
    required this.year,
    this.imageUrl,
  });

  // Factory constructor to create a Student from a Map (Firestore document)
  factory Student.fromMap(Map<String, dynamic> map, String documentId) {
    return Student(
      id: documentId,
      name: map['name'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      course: map['course'] ?? '',
      year: map['year'] ?? 1,
      imageUrl: map['imageUrl'],
    );
  }

  // Convert Student to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rollNumber': rollNumber,
      'course': course,
      'year': year,
      'imageUrl': imageUrl,
    };
  }
}