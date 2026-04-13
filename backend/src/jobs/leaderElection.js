// Alternatively handled directly inside the job process with redis locks like in dailyBackup.job.js
import redisClient from '../config/redis.js';

export const startLeaderElection = () => {
  setInterval(async () => {
    const lock = await redisClient.set('leader:backup', 'node', 'NX', 'EX', 60);
    if (lock) {
      // This instance is leader
      // Can safely run singleton scheduling logic here
    }
  }, 30000);
};

export default { startLeaderElection };
