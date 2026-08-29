// =============================================================
// validation_mixin.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/mixins/validation_mixin.dart)
// =============================================================

// mixin ValidationMixin :
//   validateEmail(value)    -> required + email regex -> error text or null
//   validatePassword(value) -> required + min 6 chars -> error text or null
//   validateRequired(value, fieldName) -> empty -> '<fieldName> is required' else null
