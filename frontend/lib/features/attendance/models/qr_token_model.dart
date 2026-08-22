class QrTokenResponse {
  final String token;
  final int expiresIn;

  QrTokenResponse({
    required this.token,
    required this.expiresIn,
  });

  factory QrTokenResponse.fromJson(Map<String, dynamic> json) {
    return QrTokenResponse(
      token: json['token'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }
}
