import express from 'express';
import mongoose from 'mongoose';
import redisClient from '../../config/redis.js';

const router = express.Router();

router.get('/', (req, res) => {
  const mongoStatus = mongoose.connection.readyState === 1 ? 'up' : 'down';
  const redisStatus = redisClient && redisClient.status === 'ready' ? 'up' : 'down';
  const cloudinaryStatus = process.env.CLOUDINARY_URL || process.env.CLOUDINARY_API_KEY ? 'up' : 'down';

  res.status(200).json({
    status: 'ok',
    mongo: mongoStatus,
    redis: redisStatus,
    cloudinary: cloudinaryStatus,
    uptime: process.uptime()
  });
});

export default router;
