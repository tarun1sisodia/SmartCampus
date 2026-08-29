// =============================================================
// user_model.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/auth/models/user_model.dart)
// (user_model.g.dart is GENERATED json code for this model — no hand-written logic)
// =============================================================

// class UserModel (Equatable, @JsonSerializable) :
//   fields: id, name, email, profilePhoto?, role, organizationId?, permissions[], lastLogin?, isActive

// fromJson(json) :
//   first _normalizeJson (below), then let the generated code map fields

// _normalizeJson(json) : make different backend shapes look the same:
//   id              <- id | _id | ''
//   profilePhoto    <- profilePhoto | avatarUrl | avatar
//   organizationId  <- organizationId | organisation._id | organisation
//   role            <- role | default 'teacher'
//   permissions     <- permissions | []
//   isActive        <- isActive | is_active | true
//   lastLogin       <- lastLogin | last_login

// toJson() -> generated serialization
