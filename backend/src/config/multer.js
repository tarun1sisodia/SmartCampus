import multer from 'multer';

/**
 * Memory storage: files are streamed into a bounded buffer, validated by
 * magic bytes, then passed to Cloudinary. This avoids writing untrusted
 * filenames to disk (path traversal) and prevents orphaned temp files.
 */
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png'];

const magicBytesMatch = (buffer, mimetype) => {
  if (!buffer || buffer.length < 4) return false;
  if (mimetype === 'image/jpeg') {
    return buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff;
  }
  if (mimetype === 'image/png') {
    return buffer[0] === 0x89 && buffer[1] === 0x50 && buffer[2] === 0x4e && buffer[3] === 0x47;
  }
  if (mimetype === 'text/csv') {
    // Basic sanity: first bytes must be printable ASCII (allow BOM).
    const head = buffer.subarray(0, 512);
    for (const byte of head) {
      const printable = (byte >= 0x20 && byte <= 0x7e) || byte === 0x0a || byte === 0x0d || byte === 0x09 || byte === 0xef || byte === 0xbb || byte === 0xbf || byte >= 0x80;
      if (!printable) return false;
    }
    return true;
  }
  return false;
};

const fileFilter = (req, file, cb) => {
  // Allow images for photos, allow csv for imports
  const allowed = [...ALLOWED_IMAGE_TYPES, 'text/csv'];
  if (!allowed.includes(file.mimetype)) {
    return cb(Object.assign(new Error('Invalid file type'), { status: 400 }), false);
  }
  cb(null, true);
};

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 2 * 1024 * 1024, // 2MB max
    files: 1,
  },
  fileFilter,
});

/** Post-multer content validation — call after the route handler receives the file. */
export const verifyUploadedContent = (req, res, next) => {
  const file = req.file;
  if (file && !magicBytesMatch(file.buffer, file.mimetype)) {
    return res.status(400).json({ success: false, message: 'File content does not match its type' });
  }
  next();
};

export default upload;
