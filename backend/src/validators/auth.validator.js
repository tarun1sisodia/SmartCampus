const { z } = require('zod');

exports.loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6)
});

exports.inviteSchema = z.object({
  email: z.string().email(),
  role: z.enum(['super_admin', 'org_admin', 'teacher']),
  name: z.string().optional()
});

exports.acceptInviteSchema = z.object({
  token: z.string().min(10),
  password: z.string().min(6),
  name: z.string().optional()
});

exports.forgotSchema = z.object({
  email: z.string().email()
});

exports.resetSchema = z.object({
  token: z.string(),
  newPassword: z.string().min(6)
});

exports.changePasswordSchema = z.object({
  oldPassword: z.string(),
  newPassword: z.string().min(6)
});
