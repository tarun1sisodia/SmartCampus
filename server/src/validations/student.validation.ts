import Joi from 'joi';

export const studentSchema = {
  create: Joi.object({
    name: Joi.string().required().min(2).max(100),
    roll_number: Joi.string().required().min(2).max(20),
    email: Joi.string().email().required(),
    course_id: Joi.string().uuid().required(),
    semester: Joi.number().required().min(1).max(12),
    section: Joi.string().required().max(10),
    profile_picture_url: Joi.string().uri().optional()
  }),

  update: Joi.object({
    name: Joi.string().optional().min(2).max(100),
    roll_number: Joi.string().optional().min(2).max(20),
    email: Joi.string().email().optional(),
    course_id: Joi.string().uuid().optional(),
    semester: Joi.number().optional().min(1).max(12),
    section: Joi.string().optional().max(10),
    profile_picture_url: Joi.string().uri().optional()
  })
};

export default studentSchema;
