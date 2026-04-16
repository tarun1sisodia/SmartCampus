import '../src/config/env.js';
import {  S3Client, ListBucketsCommand  } from '@aws-sdk/client-s3';

const s3Client = new S3Client({
  region: 'auto',
  endpoint: process.env.AWS_REGION_JURISDICTION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
});

async function testConnection() {
  console.log('--- Testing Cloudflare R2 Connectivity ---');
  console.log('Endpoint:', process.env.AWS_REGION_JURISDICTION);
  console.log('Access Key ID:', process.env.AWS_ACCESS_KEY_ID);
  
  try {
    const command = new ListBucketsCommand({});
    const data = await s3Client.send(command);
    console.log('✅ Successfully connected to R2!');
    console.log('Buckets:', data.Buckets.map(b => b.Name));
    
    if (data.Buckets.some(b => b.Name === process.env.AWS_BUCKET)) {
        console.log(`✅ Target bucket "${process.env.AWS_BUCKET}" found.`);
    } else {
        console.warn(`⚠️ Target bucket "${process.env.AWS_BUCKET}" NOT found in list.`);
    }
  } catch (err) {
    console.error('❌ Connection failed:', err.message);
    process.exit(1);
  }
}

testConnection();
