class QrVerificationRequest {
  final String sessionId;
  final String token;
  final double? lat;
  final double? lon;

  QrVerificationRequest({
    required this.sessionId,
    required this.token,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'token': token,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
  }
}
