const backupService = require('../../../src/services/backup.service');
const BackupRecord = require('../../../src/models/BackupRecord.model');
const { uploadFile } = require('../../../src/utils/s3Client');
const child_process = require('child_process');

jest.mock('../../../src/models/BackupRecord.model');
jest.mock('../../../src/utils/s3Client');
jest.mock('child_process');

describe('Backup Service Logic Tests', () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createFullBackup()', () => {

    it('Successfully invokes mongodump, pipes to s3 client, and logs a successful database status update', async () => {
      
      // Arrange Mocks
      // Fake child process shell sequence resolving correctly.
      child_process.exec.mockImplementation((cmd, callback) => callback(null, 'stdout', 'stderr'));
      uploadFile.mockResolvedValue('s3-url-to-payload-archive');
      BackupRecord.create.mockResolvedValue({ _id: 'fakeBackupID007', status: 'completed' });
      
      // Act
      const backupResult = await backupService.createFullBackup('superuser_trigger_123', null);

      // Assert Node System Invocations
      // Did we tell the OS specifically to trigger a gzip formatted mongodump inside /tmp?
      expect(child_process.exec).toHaveBeenCalledWith(
        expect.stringMatching(/mongodump --archive=\/tmp\/backup_.*\.gz --gzip --db=.*smartcampus/),
        expect.any(Function)
      );
      
      // Did we upload the specific generated temporary hash file to S3?
      expect(uploadFile).toHaveBeenCalledWith(
        expect.stringMatching(/\/tmp\/backup_.*\.gz/), 
        expect.stringMatching(/backups\/full_.*\.gz/)
      );

      // Did we verify the record to the frontend reporting UI tracking the AWS linkage?
      expect(BackupRecord.create).toHaveBeenCalledWith(expect.objectContaining({
        triggeredBy: 'superuser_trigger_123',
        status: 'completed',
        backupType: 'full',
      }));
      
      expect(backupResult._id).toBe('fakeBackupID007');
    });

    it('Properly aborts and flags the DB audit log heavily if the aws sdk / upload crashes', async () => {
      // Arrange
      child_process.exec.mockImplementation((cmd, callback) => callback(null, 'stdout', 'stderr'));
      uploadFile.mockRejectedValue(new Error('S3 Access Denied Exception Mocked'));
      BackupRecord.create.mockResolvedValue({ status: 'failed' });

      // Act & Assert
      await expect(backupService.createFullBackup('superuser_trigger_123', null)).rejects.toThrow('S3 Access Denied Exception Mocked');
      
      expect(BackupRecord.create).toHaveBeenCalledWith(expect.objectContaining({
        status: 'failed', // Should forcefully trace that the backend caught the S3 blackout
      }));
    });
  });
});
