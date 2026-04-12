// Alternatively handled directly inside the job process with redis locks like in dailyBackup.job.js
const redisClient = require('../config/redis');

exports.startLeaderElection = () => {
  setInterval(async () => {
    const lock = await redisClient.set('leader:backup', 'node', 'NX', 'EX', 60);
    if (lock) {
      // This instance is leader
      // Can safely run singleton scheduling logic here
    }
  }, 30000);
};
