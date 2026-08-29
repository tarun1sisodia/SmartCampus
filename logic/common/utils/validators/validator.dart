// =============================================================
// validator.dart  ->  ALGORITHM ONLY (source: frontend/lib/common/utils/validators/validator.dart)
// =============================================================

// class TValidator (static, each returns error text or null when valid) :
//   email(value)       -> required + email regex must match
//   password(value)    -> required, min 6 chars, needs uppercase + digit + special char
//   phoneNumber(value) -> required, exactly 10 digits
//   name(value)        -> required, min 2 chars, letters + spaces only
//   price(value)       -> required, parseable number > 0
//   quantity(value)    -> required, parseable integer >= 0
//   cardNumber(value)  -> strip spaces/dashes, must be 16 digits
//   cvv(value)         -> 3-4 digits
//   date(value)        -> MM/YY format
//   postalCode(value)  -> required + format check
