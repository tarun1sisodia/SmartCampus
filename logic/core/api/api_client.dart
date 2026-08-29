// =============================================================
// api_client.dart  ->  ALGORITHM ONLY (source: frontend/lib/core/api/api_client.dart)
// The single HTTP client (Dio) used by every repository.
// =============================================================

// import: dio, env_config, token_interceptor, refresh_token_interceptor, secure_storage_service

// class ApiClient :
//   constructor :
//     create Dio with baseUrl from EnvConfig.apiBaseUrl
//     timeouts: connect + receive = 30 seconds each
//     default headers: Content-Type json + Accept json
//     attach TokenInterceptor        -> adds "Authorization: Bearer <token>" to every request
//     attach RefreshTokenInterceptor -> auto-recovers from 401 by refreshing the token and retrying
//     in debug mode only -> also attach LogInterceptor (full request/response logs)
//   getter dio -> expose the Dio instance so repositories call .get/.post on it
