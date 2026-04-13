class FeedbackModel {
  final String userId;
  final String? userEmail;
  final int rating;
  final String feedback;
  final DateTime createdAt;

  FeedbackModel({
    required this.userId,
    this.userEmail,
    required this.rating,
    required this.feedback,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'rating': rating,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
    };
    
    if (userEmail != null) {
      data['user_email'] = userEmail;
    }
    
    return data;
  }
}