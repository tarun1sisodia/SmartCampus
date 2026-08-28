import User from '../models/User.model.js';
import Organisation from '../models/Organisation.model.js';
import crypto from 'crypto';
import emailService from './email.service.js';
import eventBus from './eventBus.service.js';
import { generateAccessToken, generateRefreshToken } from '../utils/generateToken.js';
import RefreshToken from '../models/RefreshToken.model.js';
import { hashToken } from './auth.service.js';

/** Role hierarchy for invitations:
 *  - super_admin may invite org_admin and teacher into any organisation
 *  - org_admin may invite teachers into their own organisation only
 *  - nobody may invite another super_admin (seeded/bootstrap only)
 */
const INVITABLE_ROLES = {
  super_admin: ['org_admin', 'teacher'],
  org_admin: ['teacher'],
};

export const createInvite = async (inviterId, targetEmail, role, organisationId, name) => {
  const inviter = await User.findById(inviterId);
  if (!inviter) throw new Error('Inviter not found');

  const allowed = INVITABLE_ROLES[inviter.role] || [];
  if (!allowed.includes(role)) {
    throw Object.assign(
      new Error(`Your role cannot invite users with the "${role}" role`),
      { status: 403 }
    );
  }

  const org = await Organisation.findById(organisationId);
  if (!org) throw Object.assign(new Error('Organisation not found'), { status: 404 });
  if (org.status === 'suspended') {
    throw Object.assign(new Error('Organisation is suspended'), { status: 400 });
  }

  const normalizedEmail = String(targetEmail || '').trim().toLowerCase();
  const existingUser = await User.findOne({ email: normalizedEmail });

  if (existingUser && existingUser.isActive) {
    throw Object.assign(new Error('User already exists and is active'), { status: 409 });
  }

  // Enforce the org's teacher seat limit for non-super-admin creators.
  if (role === 'teacher' && inviter.role !== 'super_admin') {
    const teacherCount = await User.countDocuments({ organisation: organisationId, role: 'teacher' });
    const max = org.subscription?.maxTeachers ?? 10;
    if (!existingUser && teacherCount >= max) {
      throw Object.assign(
        new Error(`Teacher limit reached for your organisation's plan (max ${max})`),
        { status: 402 }
      );
    }
  }

  const inviteToken = crypto.randomBytes(32).toString('hex');
  const inviteExpires = new Date();
  inviteExpires.setDate(inviteExpires.getDate() + 7);

  let user;
  if (existingUser) {
    existingUser.inviteToken = hashToken(inviteToken);
    existingUser.inviteExpires = inviteExpires;
    existingUser.invitedBy = inviterId;
    existingUser.role = role;
    existingUser.organisation = organisationId;
    if (name) existingUser.name = name;
    user = await existingUser.save();
  } else {
    user = await User.create({
      email: normalizedEmail,
      name: name || 'Invited User',
      role,
      organisation: organisationId,
      invitedBy: inviterId,
      isActive: false,
      inviteToken: hashToken(inviteToken),
      inviteExpires
    });
  }

  await emailService.sendInviteEmail(user.email, inviteToken, inviter.name || 'An Admin');
  await eventBus.publish('user.invited', { userId: user._id, email: user.email });

  return user;
};

export const acceptInvite = async (token, password, name) => {
  const user = await User.findOne({
    inviteToken: hashToken(token),
    isActive: false,
    inviteExpires: { $gt: new Date() }
  });

  if (!user) {
    throw Object.assign(new Error('Invalid or expired invitation token'), { status: 400 });
  }

  user.password = password; // Pre-save hook performs the single hash
  user.isActive = true;
  user.inviteToken = undefined;
  user.inviteExpires = undefined;
  if (name) user.name = name;

  await user.save();

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  const expires = new Date();
  expires.setDate(expires.getDate() + 7);
  await RefreshToken.create({
    tokenHash: hashToken(refreshToken),
    user: user._id,
    expiresAt: expires
  });

  return { tokens: { accessToken, refreshToken }, user: user.toJSON() };
};

export default { createInvite, acceptInvite };
