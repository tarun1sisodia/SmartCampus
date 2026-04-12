const bcrypt = require('bcrypt');

exports.hashPassword = async (plain) => {
  return await bcrypt.hash(plain, 10);
};

exports.comparePassword = async (plain, hash) => {
  return await bcrypt.compare(plain, hash);
};
