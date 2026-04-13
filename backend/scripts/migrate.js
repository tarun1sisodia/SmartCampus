import { fileURLToPath } from 'url';
import { dirname } from 'path';
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

import dotenv from 'dotenv';
dotenv.config();
import fs from 'fs';
import path from 'path';
import mongoose from 'mongoose';
import connectDB from '../src/config/database.js';

// Internal migration model to track versions
const migrationSchema = new mongoose.Schema({
  filename: String,
  appliedAt: { type: Date, default: Date.now }
});
const Migration = mongoose.model('Migration', migrationSchema);

async function startMigration() {
  await connectDB();
  
  const migrationsDir = path.join(__dirname, '../migrations');
  if (!fs.existsSync(migrationsDir)) {
    console.log('No migrations folder found.');
    process.exit(0);
  }

  const files = fs.readdirSync(migrationsDir).filter(f => f.endsWith('.js')).sort();
  
  for (const file of files) {
    const applied = await Migration.findOne({ filename: file });
    if (!applied) {
      console.log(`Applying migration: ${file}`);
      const migration = require(path.join(migrationsDir, file));
      if (migration.up) {
        await migration.up(mongoose);
      }
      await Migration.create({ filename: file });
      console.log(`Finished migration: ${file}`);
    }
  }

  console.log('All migrations applied successfully.');
  await mongoose.disconnect();
}

startMigration().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
