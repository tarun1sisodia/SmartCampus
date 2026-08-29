// =============================================================
// api_constants.dart  ->  ALGORITHM ONLY (source: frontend/lib/common/utils/constants/api_constants.dart)
// Legacy env config based on flutter_dotenv (.env file).
// =============================================================

// class ApiConstants :
//   backendBaseUrl -> from .env 'BACKEND_BASE_URL', fallback http://10.0.2.2:5000/api/v1 (android emulator host)
//   socketUrl      -> from .env 'SOCKET_URL', fallback http://10.0.2.2:5000
//   sentryDsn      -> from .env, trimmed; empty -> null (disabled)
//   isExternalImage(url) -> true only when url parses to an absolute URI
//   optimizeImageUrl(url, width, height, quality=75) :
//     append query params width/height/quality=75/resize=cover to the image url (server-side image resizing)
//     unparsable url -> return unchanged
