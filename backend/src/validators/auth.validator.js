import { z } from 'zod';

/** Shared password policy: min 8 chars with upper, lower and digit. */
export const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .max(128)
  .regex(/[a-z]/, 'Password must contain a lowercase letter')
  .regex(/[A-Z]/, 'Password must contain an uppercase letter')
  .regex(/[0-9]/, 'Password must contain a digit');

export const loginSchema = z.object({
  email: z.string().email().max(254),
  password: z.string().min(1).max(128)
});

export const inviteSchema = z.object({
  email: z.string().email().max(254),
  role: z.enum(['super_admin', 'org_admin', 'teacher']),
  name: z.string().trim().max(120).optional(),
  organisationId: z.string().max(64).optional()
});

export const acceptInviteSchema = z.object({
  token: z.string().min(10).max(128),
  password: passwordSchema,
  name: z.string().trim().max(120).optional()
});

export const forgotSchema = z.object({
  email: z.string().email().max(254)
});

export const resetSchema = z.object({
  token: z.string().min(10).max(128),
  newPassword: passwordSchema
});

export const changePasswordSchema = z.object({
  oldPassword: z.string().min(1).max(128),
  newPassword: passwordSchema
});

export const updateProfileSchema = z.object({
  name: z.string().trim().min(1).max(120).optional(),
  contact: z.string().trim().max(32).optional()
});

export const updateRoleSchema = z.object({
  role: z.enum(['super_admin', 'org_admin', 'teacher'])
});

export default {
  loginSchema,
  inviteSchema,
  acceptInviteSchema,
  forgotSchema,
  resetSchema,
  changePasswordSchema,
  updateProfileSchema,
  updateRoleSchema,
};
