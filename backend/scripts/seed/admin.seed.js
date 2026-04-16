import User from '../../src/models/User.model.js';
import logger from '../../src/config/logger.js';

export async function seedAdmins() {
  const superAdminEmail = process.env.SUPER_ADMIN_EMAIL || 'super@smartcampus.com';
  const existingSuper = await User.findOne({ email: superAdminEmail });
  
  if (!existingSuper) {
    await User.create({
      name: 'Super Admin',
      email: superAdminEmail,
      password: process.env.SUPER_ADMIN_PASSWORD || 'SuperSecret123',
      role: 'super_admin',
      isActive: true,
    });
    console.log('✅ Super Admin created');
  } else {
    console.log('ℹ️ Super Admin already exists');
  }
}
