// =============================================================
// multer.js  ->  ALGORITHM ONLY (source: backend/src/config/multer.js)
// Upload handling in memory (never writes untrusted files to disk).
// =============================================================

// upload = multer:
//   storage: memoryStorage()            -> file lives in a buffer only
//   limits: 2MB max, exactly 1 file
//   fileFilter: only jpeg/png images + text/csv allowed; else 400 'Invalid file type'

// magicBytesMatch(buffer, mimetype) -> verify real file content, not just the header claim:
//   jpeg -> bytes FF D8 FF ; png -> 89 50 4E 47 ; csv -> first 512 bytes must be printable ascii

// verifyUploadedContent (route middleware, run AFTER multer):
//   file present AND content doesn't match its claimed type -> 400 'content does not match type'
