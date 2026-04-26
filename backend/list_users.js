import dotenv from 'dotenv';
dotenv.config();
import mongoose from 'mongoose';
import User from './src/models/User.model.js';

async function run() {
  await mongoose.connect(process.env.MONGO_URI);
  const users = await User.find({ role: { $in: ['super_admin', 'org_admin'] } }, 'email role');
  console.log('Users:', users);
  process.exit(0);
}
run();
