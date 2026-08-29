// =============================================================
// token_interceptor.dart  ->  ALGORITHM ONLY (source: frontend/lib/core/api/token_interceptor.dart)
// =============================================================

// class TokenInterceptor (Dio Interceptor) :
//   onRequest(options, handler) :
//     read access token from secure storage
//     if token exists -> set header "Authorization: Bearer <token>"
//     continue the request (guest requests simply go out without the header)
