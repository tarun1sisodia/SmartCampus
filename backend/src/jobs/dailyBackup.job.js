const { backupQueue } = require('../config/bull');
const backupService = require('../services/backup.service');
const redisClient = require('../config/redis');

exports.setupDailyBackup = () => {
  backupQueue.process('daily-backup', async (job) => {
    // Acquire distributed lock to ensure only one worker runs this
    const lockKey = 'lock:daily-backup';
    const lockAquired = await redisClient.setnx(lockKey, 'locked');
    if (!lockAquired) {
      return Promise.resolve({ skipped: true, reason: 'Lock not acquired' });
    }
    
    // Expire the lock after 2 hours
    await redisClient.expire(lockKey, 2 * 60 * 60);

    try {
      await backupService.createFullBackup(null, null);
    } finally {
      await redisClient.del(lockKey);
    }
  });

  backupQueue.add('daily-backup', {}, { repeat: { cron: '0 2 * * *' } });
};
