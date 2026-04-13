import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._() {
    //print('ApiConstants initialized');
  }

  static String get backendBaseUrl => dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:5000/api/v1';
  static String get socketUrl => dotenv.env['SOCKET_URL'] ?? 'http://10.0.2.2:5000';

  static String? get sentryDsn {
    final value = dotenv.env['SENTRY_DSN']?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static bool isExternalImage(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.isAbsolute;
  }

  static String optimizeImageUrl(
    String url, {
    int? width,
    int? height,
    int quality = 75,
  }) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return url;
    }

    final query = Map<String, String>.from(uri.queryParameters);
    if (width != null) {
      query['width'] = width.toString();
    }
    if (height != null) {
      query['height'] = height.toString();
    }
    query.putIfAbsent('quality', () => quality.toString());
    query.putIfAbsent('resize', () => 'cover');

    return uri.replace(queryParameters: query).toString();
  }

  static String _requireEnv(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable: $key. Update .env before launching the app.',
      );
    }
    return value;
  }
}
