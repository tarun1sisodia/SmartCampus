const { z } = require('zod');
const { Types } = require('mongoose');

const objectIdSchema = z.custom((val) => Types.ObjectId.isValid(val), "Invalid ObjectId");

exports.markAttendanceSchema = z.object({
  sessionId: objectIdSchema,
  attendance: z.array(z.object({
    studentId: objectIdSchema,
    status: z.enum(['present', 'absent', 'late', 'excused']),
    remarks: z.string().optional()
  }))
});
