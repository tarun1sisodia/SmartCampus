import { z } from "zod";

export const organisationSchema = z.object({
  name: z.string().trim().min(2, "Name is required"),
  type: z.enum(["school", "college"]),
  domain: z.string().trim().optional(),
  contactEmail: z.string().trim().email("Valid contact email is required"),
  address: z.string().trim().optional(),
  subscriptionPlan: z.enum(["basic", "premium", "enterprise"]),
  status: z.enum(["active", "suspended"]).optional()
});

export type OrganisationFormValues = z.infer<typeof organisationSchema>;
