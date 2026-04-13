import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._() {
    //print('ApiConstants initialized');
  }

  static String get url => _requireEnv('SUPABASE_URL');

  static String get anonKey => _requireEnv('SUPABASE_ANON_KEY');

  static String? get sentryDsn {
    final value = dotenv.env['SENTRY_DSN']?.trim();
    return value == null || value.isEmpty ? null : value;
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

    final isSupabaseStorage =
        uri.host.contains('supabase.co') && uri.path.contains('/storage/');
    if (!isSupabaseStorage) {
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
