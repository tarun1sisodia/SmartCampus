// Alternatively handled directly inside the job process with redis locks like in dailyBackup.job.js
import redisClient from '../config/redis.js';

export const startLeaderElection = () => {
  setInterval(async () => {
    try {
      const lockKey = 'leader:singleton-tasks';
      const isLeader = await redisClient.set(lockKey, 'active', 'NX', 'EX', 60);
      
      if (isLeader) {
        // This node is currently the leader. 
        // Unique singleton logic (cleanup, report triggers) can happen here.
      }
    } catch (err) {
      // Slient fail, will retry in next interval
    }
  }, 30000);
};

export default { startLeaderElection };
