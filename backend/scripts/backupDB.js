require('dotenv').config();
const backupService = require('../src/services/backup.service');
const connectDB = require('../src/config/database');
const mongoose = require('mongoose');

async function runBackup() {
  await connectDB();
  
  try {
    const orgId = process.argv[2] === 'null' ? null : process.argv[2];
    console.log('Starting backup process...');
    const record = await backupService.createFullBackup(null, orgId);
    console.log('Backup successful:', record);
  } catch (err) {
    console.error('Backup failed:', err);
  } finally {
    await mongoose.disconnect();
  }
}

runBackup();
