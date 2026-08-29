// =============================================================
// location_service.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/repositories/location_service.dart)
// =============================================================

// class LocationService :

// getCurrentLocation() -> Position? :
//   if location service OFF on the device            -> return null
//   if permission denied -> ask once; still denied   -> return null
//   if permission denied FOREVER                     -> return null (user must fix in settings)
//   all good -> return the current GPS position
//   (null simply means "no location", callers still verify the QR without it)
