class ClassGroup {
  final String id;
  final String degree;
  final int year;
  final String subject;
  final String teacherId;
  final List<String> studentIds; // References to student documents

  ClassGroup({
    required this.id,
    required this.degree,
    required this.year,
    required this.subject,
    required this.teacherId,
    required this.studentIds,
  });

  // Factory constructor to create a ClassGroup from a Map (Firestore document)
  factory ClassGroup.fromMap(Map<String, dynamic> map, String documentId) {
    return ClassGroup(
      id: documentId,
      degree: map['degree'] ?? '',
      year: map['year'] ?? 1,
      subject: map['subject'] ?? '',
      teacherId: map['teacherId'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }

  // Convert ClassGroup to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'year': year,
      'subject': subject,
      'teacherId': teacherId,
      'studentIds': studentIds,
    };
  }
}