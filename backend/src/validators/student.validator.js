const { z } = require('zod');
const { Types } = require('mongoose');

// Helper for Mongo ID validation
const objectIdSchema = z.custom((val) => Types.ObjectId.isValid(val), "Invalid ObjectId");

exports.createStudentSchema = z.object({
  rollNumber: z.string().min(1),
  name: z.string().min(2),
  courseId: objectIdSchema,
  semesterId: objectIdSchema,
  sectionId: objectIdSchema,
  email: z.string().email().optional()
});
