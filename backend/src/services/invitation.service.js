import User from '../models/User.model.js';
import crypto from 'crypto';
import emailService from './email.service.js';
import eventBus from './eventBus.service.js';
import { generateAccessToken, generateRefreshToken } from '../utils/generateToken.js';
import RefreshToken from '../models/RefreshToken.model.js';
import bcrypt from 'bcrypt';

export const createInvite = async (inviterId, targetEmail, role, organisationId, name) => {
  const existingUser = await User.findOne({ email: targetEmail });
  
  if (existingUser && existingUser.isActive) {
    throw new Error('User already exists and is active');
  }

  const inviteToken = crypto.randomBytes(32).toString('hex');
  const inviteExpires = new Date();
  inviteExpires.setDate(inviteExpires.getDate() + 7);

  let user;
  if (existingUser) {
    existingUser.inviteToken = inviteToken;
    existingUser.inviteExpires = inviteExpires;
    existingUser.invitedBy = inviterId;
    existingUser.role = role;
    existingUser.organisation = organisationId;
    if (name) existingUser.name = name;
    user = await existingUser.save();
  } else {
    user = await User.create({
      email: targetEmail,
      name: name || 'Invited User',
      role,
      organisation: organisationId,
      invitedBy: inviterId,
      isActive: false,
      inviteToken,
      inviteExpires
    });
  }

  const inviter = await User.findById(inviterId);
  await emailService.sendInviteEmail(targetEmail, inviteToken, inviter ? inviter.name : 'An Admin');
  await eventBus.publish('user.invited', { userId: user._id, email: targetEmail });

  return user;
};

export const acceptInvite = async (token, password, name) => {
  const user = await User.findOne({ 
    inviteToken: token, 
    isActive: false, 
    inviteExpires: { $gt: new Date() } 
  });

  if (!user) {
    throw new Error('Invalid or expired invitation token');
  }

  user.password = password; // Pre-save hook will hash it
  user.isActive = true;
  user.inviteToken = undefined;
  user.inviteExpires = undefined;
  if (name) user.name = name;

  await user.save();
  
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  // Store refresh token
  const hashedRToken = await bcrypt.hash(refreshToken, 10);
  const expires = new Date();
  expires.setDate(expires.getDate() + 7);
  await RefreshToken.create({ token: hashedRToken, user: user._id, expiresAt: expires });

  return { tokens: { accessToken, refreshToken }, user: user.toJSON() };
};

export default { createInvite, acceptInvite };
