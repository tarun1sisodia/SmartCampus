// =============================================================
// s3Client.js  ->  ALGORITHM ONLY (source: backend/src/utils/s3Client.js)
// =============================================================

// S3Client with endpoint from AWS_REGION_JURISDICTION + creds from env (fake keys fallback)
// uploadFile(bucket, key, localFilePath) -> stream a local file up (used by the backup service)
// downloadFile(bucket, key) -> GetObjectCommand (restore path)
