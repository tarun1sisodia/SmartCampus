import {  z  } from 'zod';
import {  Types  } from 'mongoose';

const objectIdSchema = z.custom((val) => Types.ObjectId.isValid(val), "Invalid ObjectId");

export const markAttendanceSchema = z.object({
  sessionId: objectIdSchema,
  attendance: z.array(z.object({
    studentId: objectIdSchema,
    status: z.enum(['present', 'absent', 'late', 'excused']),
    remarks: z.string().optional()
  }))
});

export default { markAttendanceSchema };
