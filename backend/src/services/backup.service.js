const BackupRecord = require('../models/BackupRecord.model');
// Actual system command runners like 'exec' to run mongodump
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const { uploadFile } = require('../utils/s3Client');
const path = require('path');
const fs = require('fs');

exports.createFullBackup = async (triggeredBy, organisationId = null) => {
  const timestamp = new Date().getTime();
  const filename = `backup_${timestamp}.gz`;
  const localFilePath = path.join('/tmp', filename);

  let dumpCmd = `mongodump --archive=${localFilePath} --gzip --uri="${process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus'}"`;
  
  // Create an initial record
  const record = await BackupRecord.create({
    organisation: organisationId,
    backupType: 'full',
    status: 'pending',
    startedAt: new Date(),
    triggeredBy
  });

  try {
    await execPromise(dumpCmd);

    const s3Key = `backups/${filename}`;
    await uploadFile(process.env.AWS_BACKUP_BUCKET || 'smartcampus-backups', s3Key, localFilePath);

    const stats = fs.statSync(localFilePath);
    
    record.status = 'completed';
    record.completedAt = new Date();
    record.s3Key = s3Key;
    record.sizeBytes = stats.size;
    await record.save();

    // Clean up
    fs.unlinkSync(localFilePath);
    return record;

  } catch (err) {
    record.status = 'failed';
    record.completedAt = new Date();
    await record.save();
    throw err;
  }
};
