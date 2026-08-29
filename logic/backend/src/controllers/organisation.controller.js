// =============================================================
// organisation.controller.js  ->  ALGORITHM ONLY (source: backend/src/controllers/organisation.controller.js)
// =============================================================

// create : whitelisted fields -> 201
// list : pagination + status/type filters
// get : by id
// update (PATCH) :
//   action 'suspend'  -> status suspended + deactivate all non-super users of that org
//   action 'activate' -> status active
//   else generic whitelisted findByIdAndUpdate
