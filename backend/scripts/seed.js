import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import User from '../src/models/User.model.js';
import Organisation from '../src/models/Organisation.model.js';

async function seed() {
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus');

  // 1. Create super admin (if not exists)
  const superAdminEmail = process.env.SUPER_ADMIN_EMAIL || 'super@smartcampus.com';
  const existingSuper = await User.findOne({ role: 'super_admin' });
  if (!existingSuper) {
    // Note: User.model automatically hashes the plaintext password in pre-save.
    await User.create({
      name: 'Super Admin',
      email: superAdminEmail,
      password: process.env.SUPER_ADMIN_PASSWORD || 'ChangeMe123!',
      role: 'super_admin',
      isActive: true,
    });
    console.log('✅ Super admin created');
  } else {
    console.log('ℹ️ Super admin already exists');
  }

  // 2. Create a demo organisation (optional)
  let demoOrg = await Organisation.findOne({ name: 'Demo School' });
  if (!demoOrg) {
    demoOrg = await Organisation.create({
      name: 'Demo School',
      type: 'school',
      status: 'active',
      subscription: { plan: 'premium', maxTeachers: 50, maxStudents: 1000 },
    });
    console.log('✅ Demo organisation created');

    // 3. Create an org admin for the demo organisation
    const orgAdminExists = await User.findOne({ email: 'admin@demoschool.com' });
    if (!orgAdminExists) {
      // Note: User.model automatically hashes the plaintext password in pre-save.
      await User.create({
        name: 'Demo Admin',
        email: 'admin@demoschool.com',
        password: process.env.DEMO_ADMIN_PASSWORD || 'ChangeMe123!',
        role: 'org_admin',
        organisation: demoOrg._id,
        isActive: true,
      });
      console.log(`✅ Org admin created: admin@demoschool.com / ${process.env.DEMO_ADMIN_PASSWORD || 'Check .env'}`);
    }
  } else {
    console.log('ℹ️ Demo organisation already exists');
  }

  await mongoose.disconnect();
  process.exit(0);
}

seed().catch(err => { 
  console.error(err); 
  process.exit(1); 
});
