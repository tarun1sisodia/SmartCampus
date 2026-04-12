const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const fs = require('fs');

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'fakeAccessKey',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'fakeSecretKey'
  }
});

exports.s3Client = s3Client;

exports.uploadFile = async (bucket, key, localFilePath) => {
  const fileStream = fs.createReadStream(localFilePath);
  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: fileStream,
  });
  return await s3Client.send(command);
};

exports.downloadFile = async (bucket, key) => {
  const command = new GetObjectCommand({
    Bucket: bucket,
    Key: key
  });
  return await s3Client.send(command);
};
