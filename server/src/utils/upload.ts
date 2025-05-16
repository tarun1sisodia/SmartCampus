import multer from 'multer';
import path from 'path';
import { BadRequestError } from './error';

// Configure storage for different file types
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    let uploadPath = path.join(__dirname, '../../uploads');
    
    // Different paths for different file types
    if (file.mimetype.startsWith('image/')) {
      uploadPath = path.join(uploadPath, 'images');
    } else if (file.mimetype === 'text/csv') {
      uploadPath = path.join(uploadPath, 'csv');
    }
    
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    // Create unique filename with timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter function
const fileFilter = (req: Express.Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  if (file.fieldname === 'profilePicture') {
    // Allow only images for profile pictures
    if (!file.mimetype.startsWith('image/')) {
      cb(new BadRequestError('Only image files are allowed for profile pictures'));
      return;
    }
  } else if (file.fieldname === 'csvFile') {
    // Allow only CSV files for data import
    if (file.mimetype !== 'text/csv') {
      cb(new BadRequestError('Only CSV files are allowed for data import'));
      return;
    }
  }
  cb(null, true);
};

// Create multer instance with configuration
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  }
});

// Export configured middlewares for different upload types
export const uploadProfilePicture = upload.single('profilePicture');
export const uploadCSV = upload.single('csvFile');

export default upload;
