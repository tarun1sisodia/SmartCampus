const { emailQueue } = require('../config/bull');

exports.sendInviteEmail = async (to, token, inviterName) => {
  const inviteLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/accept-invite?token=${token}`;
  
  const htmlContent = `
    <h2>You have been invited!</h2>
    <p>${inviterName} has invited you to join SmartCampus.</p>
    <p>Please click the link below to accept your invitation and set your password:</p>
    <a href="${inviteLink}">Accept Invitation</a>
  `;

  // Push to Bull queue for async processing
  const job = await emailQueue.add({
    to,
    subject: 'Invitation to SmartCampus',
    html: htmlContent
  });

  return job.id;
};

exports.sendBulkEmail = async (recipients, subject, html) => {
  for (const recipient of recipients) {
    await emailQueue.add({
      to: recipient,
      subject,
      html
    });
  }
};

exports.sendPasswordResetEmail = async (to, token) => {
  const resetLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${token}`;
  
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
