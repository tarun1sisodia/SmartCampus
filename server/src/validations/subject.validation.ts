import Joi from 'joi';

export const subjectSchema = {
  create: Joi.object({
    name: Joi.string().required().min(3).max(100),
    code: Joi.string().required().min(2).max(20),
    course_id: Joi.string().uuid().required(),
    semester: Joi.number().required().min(1).max(12),
    description: Joi.string().optional().max(500)
  }),

  update: Joi.object({
    name: Joi.string().optional().min(3).max(100),
    code: Joi.string().optional().min(2).max(20),
    course_id: Joi.string().uuid().optional(),
    semester: Joi.number().optional().min(1).max(12),
    description: Joi.string().optional().max(500)
  })
};

export default subjectSchema;
