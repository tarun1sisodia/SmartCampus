import {  z  } from 'zod';

export const createOrgSchema = z.object({
  name: z.string().min(2),
  type: z.enum(['school', 'college']),
  domain: z.string().optional(),
  contactEmail: z.string().email()
});

export default { createOrgSchema };
