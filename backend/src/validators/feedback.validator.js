const { z } = require('zod');

exports.feedbackSchema = z.object({
  rating: z.number().min(1).max(5),
  comment: z.string().optional()
});
