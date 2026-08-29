// =============================================================
// validation.middleware.js  ->  ALGORITHM ONLY (source: backend/src/middleware/validation.middleware.js)
// Zod schema validation middleware.
// =============================================================

// validate(schema, source = 'body'|'query'|'params') :
//   schema.parse(req[source]) -> on success REPLACE req[source] with the parsed
//     (sanitised) data so handlers only ever see clean values ; next()
//   zod failure -> 400 { message:'Validation failed', errors:[{path, message}] }
