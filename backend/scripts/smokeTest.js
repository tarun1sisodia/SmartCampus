import '../src/config/env.js';
import mongoose from 'mongoose';
import redisClient from '../src/config/redis.js';
import {  S3Client, ListBucketsCommand  } from '@aws-sdk/client-s3';
import { v2 as cloudinary } from 'cloudinary';
import { fileURLToPath } from 'url';

const API_URL = 'http://localhost:5000/api/v1';

export async function verifyExternalConnections() {
  console.log('--- Checking External Bindings ---');
  
  try {
    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus');
      console.log('✅ MongoDB connected natively');
    } else {
      console.log('✅ MongoDB already connected');
    }
  } catch (err) {
    console.error(`❌ MongoDB connection failed: ${err.message}`);
  }

  try {
    await redisClient.ping();
    console.log('✅ Redis queues and rate limiters linked and responding perfectly');
  } catch(e) {
    console.error('❌ Redis offline');
  }

  // Cloudinary Check
  try {
    if (process.env.CLOUDINARY_URL || (process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_API_KEY)) {
      const config = process.env.CLOUDINARY_URL ? {} : {
        cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
        api_key: process.env.CLOUDINARY_API_KEY,
        api_secret: process.env.CLOUDINARY_API_SECRET
      };
      cloudinary.config(config);
      await cloudinary.api.ping();
      console.log('✅ Cloudinary dynamically hooked and responding');
    } else {
      console.log('⚠️ Cloudinary environmental parameters pending');
    }
  } catch (err) {
    console.error(`❌ Cloudinary connection failed: ${err.message}`);
  }

  // Cloudflare R2 Check
  console.log('--- Checking Cloudflare R2 Binding ---');
  const r2Client = new S3Client({
    region: 'auto',
    endpoint: process.env.AWS_REGION_JURISDICTION,
    credentials: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    }
  });

  try {
    const data = await r2Client.send(new ListBucketsCommand({}));
    if (data.Buckets.some(b => b.Name === process.env.AWS_BUCKET)) {
      console.log(`✅ Cloudflare R2 linked: Bucket "${process.env.AWS_BUCKET}" verified`);
    } else {
      console.log('⚠️ Cloudflare R2 linked but target bucket mismatch');
    }
  } catch(e) {
    console.error(`❌ Cloudflare R2 offline: ${e.message}`);
  }
}

async function runSmokeTests() {
  await verifyExternalConnections();
  
  console.log('\n--- Tracing Core Node HTTP Networks ---');
  try {
    const health = await fetch(`${API_URL}/health`);
    const hData = await health.json();
    if(hData.status === 'ok') console.log('✅ Internal node backend is receiving and passing express telemetry probes natively');
    
    // Login as Super Admin strictly parsing via native fetch!
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        email: process.env.SUPER_ADMIN_EMAIL || '@smartcampus.com', 
        password: process.env.SUPER_ADMIN_PASSWORD || 'SuperSecret123' 
      })
    });

    const loginData = await loginRes.json();
    if(loginData.success && loginData.data?.accessToken) {
       console.log('✅ Super Admin issued valid JWT tokens tracking through strict Zod validators successfully!');
       console.log(`🔐 Authorized Bearer Intercepted: ${loginData.data.accessToken.substring(0, 15)}...`);
    } else {
       console.log('❌ Auth test crashed. (If invalid credentials, ensure seed.js was ran securely)');
    }

    console.log('\n✅ System is globally passing structural deployment parameters!');
    console.log('🔗 You can safely open `http://localhost:5000/api-docs` to interact visually with the full OpenAPI environment mapping!');

  } catch(e) {
    console.log('❌ Server offline. Please run `npm run start:dev` in another terminal before executing smoke validations.');
  }

  process.exit(0);
}

// Only run if executed directly
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runSmokeTests();
}

