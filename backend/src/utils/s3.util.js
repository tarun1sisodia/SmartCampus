import {  S3Client, PutObjectCommand, DeleteObjectCommand  } from '@aws-sdk/client-s3';

let s3Client;

if (process.env.AWS_REGION_JURISDICTION && process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  s3Client = new S3Client({
    region: 'auto',
    endpoint: process.env.AWS_REGION_JURISDICTION,
    credentials: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    }
  });
}

export const uploadFile = async (bucket, key, fileBuffer, mimetype) => {
  if (!s3Client) {
    console.warn('S3 is not configured. Mocking upload.');
    return `https://${bucket}.s3.amazonaws.com/${key}`;
  }

  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: fileBuffer,
    ContentType: mimetype
  });

  await s3Client.send(command);
  // Using the R2 endpoint as the base for the URL
  return `${process.env.AWS_REGION_JURISDICTION}/${bucket}/${key}`;
};

export const deleteFile = async (bucket, key) => {
  if (!s3Client) {
    console.warn('S3 is not configured. Mocking delete.');
    return true;
  }

  const command = new DeleteObjectCommand({
    Bucket: bucket,
    Key: key
  });

  await s3Client.send(command);
  return true;
};

export default { uploadFile, deleteFile };
