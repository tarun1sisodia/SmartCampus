import bcrypt from 'bcrypt';

export const hashPassword = async (plain) => {
  return await bcrypt.hash(plain, 10);
};

export const comparePassword = async (plain, hash) => {
  return await bcrypt.compare(plain, hash);
};

export default { hashPassword, comparePassword };
