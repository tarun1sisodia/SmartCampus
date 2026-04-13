const backupService = require('../../src/services/backup.service');
const BackupRecord = require('../../src/models/BackupRecord.model');
const { uploadFile } = require('../../src/utils/s3Client');
const child_process = require('child_process');
const fs = require('fs');

jest.mock('../../src/models/BackupRecord.model');
jest.mock('../../src/utils/s3Client');
jest.mock('child_process');
jest.mock('fs');

describe('Backup Service Logic Tests', () => {

  beforeEach(() => {
    jest.clearAllMocks();
    fs.statSync.mockReturnValue({ size: 1024 });
    fs.unlinkSync.mockReturnValue();
  });

  describe('createFullBackup()', () => {

    it('Successfully invokes mongodump, pipes to s3 client, and logs a successful database status update', async () => {
      
      // Arrange Mocks
      // Fake child process shell sequence resolving correctly.
      child_process.exec.mockImplementation((cmd, callback) => callback(null, 'stdout', 'stderr'));
      uploadFile.mockResolvedValue('s3-url-to-payload-archive');
      
      const mockRecord = { _id: 'fakeBackupID007', status: 'pending', save: jest.fn().mockResolvedValue(true) };
      BackupRecord.create.mockResolvedValue(mockRecord);
      
      // Act
      const backupResult = await backupService.createFullBackup('superuser_trigger_123', null);

      // Assert Node System Invocations
      // Did we tell the OS specifically to trigger a gzip formatted mongodump inside /tmp?
      expect(child_process.exec).toHaveBeenCalledWith(
        expect.stringMatching(/mongodump --archive=\/tmp\/backup_.*\.gz --gzip --uri=.*/),
        expect.any(Function)
      );
      
      // Did we upload the specific generated temporary hash file to S3?
      expect(uploadFile).toHaveBeenCalledWith(
        expect.any(String), // The bucket
        expect.stringMatching(/backups\/backup_.*\.gz/), // The s3 key
        expect.stringMatching(/\/tmp\/backup_.*\.gz/)  // The local file path
      );

      expect(BackupRecord.create).toHaveBeenCalledWith(expect.objectContaining({
        triggeredBy: 'superuser_trigger_123',
        status: 'pending',
        backupType: 'full',
      }));
      
      expect(mockRecord.save).toHaveBeenCalled();
      expect(mockRecord.status).toBe('completed');
      expect(backupResult._id).toBe('fakeBackupID007');
    });

    it('Properly aborts and flags the DB audit log heavily if the aws sdk / upload crashes', async () => {
      // Arrange
      child_process.exec.mockImplementation((cmd, callback) => callback(null, 'stdout', 'stderr'));
      uploadFile.mockRejectedValue(new Error('S3 Access Denied Exception Mocked'));
      
      const mockRecord = { status: 'pending', save: jest.fn().mockResolvedValue(true) };
      BackupRecord.create.mockResolvedValue(mockRecord);

      // Act & Assert
      await expect(backupService.createFullBackup('superuser_trigger_123', null)).rejects.toThrow('S3 Access Denied Exception Mocked');
      
      expect(mockRecord.save).toHaveBeenCalled();
      expect(mockRecord.status).toBe('failed');
    });
  });
});
