import {  z  } from 'zod';

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6)
});

export const inviteSchema = z.object({
  email: z.string().email(),
  role: z.enum(['super_admin', 'org_admin', 'teacher']),
  name: z.string().optional()
});

export const acceptInviteSchema = z.object({
  token: z.string().min(10),
  password: z.string().min(6),
  name: z.string().optional()
});

export const forgotSchema = z.object({
  email: z.string().email()
});

export const resetSchema = z.object({
  token: z.string(),
  newPassword: z.string().min(6)
});

export const changePasswordSchema = z.object({
  oldPassword: z.string(),
  newPassword: z.string().min(6)
});

export default { loginSchema, inviteSchema, acceptInviteSchema, forgotSchema, resetSchema, changePasswordSchema };
