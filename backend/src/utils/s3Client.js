import {  S3Client, PutObjectCommand, GetObjectCommand  } from '@aws-sdk/client-s3';
import fs from 'fs';

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'fakeAccessKey',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'fakeSecretKey'
  }
});

// export { s3Client };

export const uploadFile = async (bucket, key, localFilePath) => {
  const fileStream = fs.createReadStream(localFilePath);
  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: fileStream,
  });
  return await s3Client.send(command);
};

export const downloadFile = async (bucket, key) => {
  const command = new GetObjectCommand({
    Bucket: bucket,
    Key: key
  });
  return await s3Client.send(command);
};

export default { s3Client, uploadFile, downloadFile };
