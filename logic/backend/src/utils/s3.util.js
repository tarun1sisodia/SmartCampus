// =============================================================
// s3.util.js  ->  ALGORITHM ONLY (source: backend/src/utils/s3.util.js)
// S3/R2 object storage helper built from explicit env credentials.
// =============================================================

// client created only when AWS_REGION_JURISDICTION + key + secret exist

// uploadFile(bucket, key, fileBuffer, mimetype) :
//   not configured -> warn + return mock url (dev fallback)
//   else PutObjectCommand -> return '<endpoint>/<bucket>/<key>' public url

// deleteFile(bucket, key) -> DeleteObjectCommand (mock true when unconfigured)
