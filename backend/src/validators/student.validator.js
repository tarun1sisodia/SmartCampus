import {  z  } from 'zod';
import {  Types  } from 'mongoose';

// Helper for Mongo ID validation
const objectIdSchema = z.custom((val) => Types.ObjectId.isValid(val), "Invalid ObjectId");

export const createStudentSchema = z.object({
  rollNumber: z.string().min(1),
  name: z.string().min(2),
  courseId: objectIdSchema,
  semesterId: objectIdSchema,
  sectionId: objectIdSchema,
  email: z.string().email().optional()
});

export default { createStudentSchema };
