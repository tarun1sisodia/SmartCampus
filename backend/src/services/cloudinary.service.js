import { v2 as cloudinary } from 'cloudinary';

// If CLOUDINARY_URL exists, the SDK naturally overrides using it!
if (!process.env.CLOUDINARY_URL) {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });
}

export const uploadImage = async (fileBuffer, folder, publicId) => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder, public_id: publicId, resource_type: 'image' },
      (error, result) => { 
        if (error) reject(error); 
        else resolve(result.secure_url); 
      }
    );
    uploadStream.end(fileBuffer);
  });
};

export const deleteImage = async (publicId) => {
  return cloudinary.uploader.destroy(publicId);
};

export default { uploadImage, deleteImage };
