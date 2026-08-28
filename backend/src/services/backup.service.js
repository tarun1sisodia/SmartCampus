import BackupRecord from '../models/BackupRecord.model.js';
// execFile (not exec) so the MONGO_URI is passed as a single argv element —
// never interpolated into a shell command.
import { execFile } from 'child_process';
import util from 'util';
const execFilePromise = util.promisify(execFile);
import { uploadFile } from '../utils/s3Client.js';
import path from 'path';
import fs from 'fs';

export const createFullBackup = async (triggeredBy, organisationId = null) => {
  const timestamp = new Date().getTime();
  const filename = `backup_${timestamp}.gz`;
  const localFilePath = path.join('/tmp', filename);

  const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus';
  const bucket = process.env.AWS_BACKUP_BUCKET || process.env.AWS_BUCKET || 'smartcampus-bucket';

  // Create an initial record
  const record = await BackupRecord.create({
    organisation: organisationId,
    backupType: 'full',
    status: 'pending',
    startedAt: new Date(),
    triggeredBy
  });

  try {
    await execFilePromise('mongodump', ['--archive=' + localFilePath, '--gzip', `--uri=${mongoUri}`], {
      timeout: 10 * 60 * 1000,
    });

    const s3Key = `backups/${filename}`;
    await uploadFile(bucket, s3Key, localFilePath);

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

export default { createFullBackup };
