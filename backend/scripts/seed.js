require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User.model');

async function seed() {
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus');

  const email = process.env.SUPER_ADMIN_EMAIL || 'superadmin@smartcampus.com';
  let admin = await User.findOne({ email });

  if (!admin) {
    admin = await User.create({
      name: 'Super Admin',
      email: email,
      password: process.env.SUPER_ADMIN_PASSWORD || 'password123',
      role: 'super_admin',
      isActive: true
    });
    console.log(`Created Super Admin: ${email}`);
  } else {
    console.log('Super Admin already exists.');
  }

  await mongoose.disconnect();
}

seed().catch(console.error);
