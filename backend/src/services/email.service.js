import { emailQueue } from '../config/bull.js';

/** Escape interpolated values before embedding them into HTML emails. */
const escapeHtml = (value = '') =>
  String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const appOrigin = () => process.env.FRONTEND_URL || 'http://localhost:3000';

export const sendInviteEmail = async (to, token, inviterName) => {
  const inviteLink = `${appOrigin()}/accept-invite?token=${encodeURIComponent(token)}`;

  const htmlContent = `
    <h2>You have been invited!</h2>
    <p>${escapeHtml(inviterName)} has invited you to join SmartCampus.</p>
    <p>Please click the link below to accept your invitation and set your password:</p>
    <a href="${inviteLink}">Accept Invitation</a>
  `;

  const job = await emailQueue.add({
    to,
    subject: 'Invitation to SmartCampus',
    html: htmlContent
  });

  return job.id;
};

export const sendBulkEmail = async (recipients, subject, html) => {
  for (const recipient of recipients) {
    await emailQueue.add({
      to: recipient,
      subject,
      html
    });
  }
};

export const sendPasswordResetEmail = async (to, token) => {
  const resetLink = `${appOrigin()}/reset-password?token=${encodeURIComponent(token)}`;

  const htmlContent = `
    <h2>Password Reset Request</h2>
    <p>You requested to reset your password.</p>
    <p>Please click the link below to set a new password:</p>
    <a href="${resetLink}">Reset Password</a>
  `;

  const job = await emailQueue.add({
    to,
    subject: 'Password Reset - SmartCampus',
    html: htmlContent
  });

  return job.id;
};

export default { sendInviteEmail, sendBulkEmail, sendPasswordResetEmail };
