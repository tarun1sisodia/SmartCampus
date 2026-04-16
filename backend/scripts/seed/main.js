import '../../src/config/env.js';
import mongoose from 'mongoose';
import { seedAdmins } from './admin.seed.js';
import { seedOrganisations } from './org.seed.js';
import { seedOrgContent } from './content.seed.js';

async function main() {
  try {
    console.log('🏁 Starting Massive Data Seeding...');
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus');

    // 1. Seed Super Admins
    await seedAdmins();

    // 2. Seed Organisations
    const orgs = await seedOrganisations();

    // 3. Seed Content for the first organization (Massive Scale)
    // Target: 501 teachers (500 for test + 1 existing/extra)
    if (orgs.length > 0) {
      await seedOrgContent(orgs[0], 505, 10); 
    }

    console.log('✨ Seeding Completed Successfully!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Seeding Failed:', err);
    process.exit(1);
  }
}

main();
