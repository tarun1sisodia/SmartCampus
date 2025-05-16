import Joi from 'joi';

export const courseSchema = {
  create: Joi.object({
    name: Joi.string().required().min(3).max(100),
    code: Joi.string().required().min(2).max(20),
    description: Joi.string().optional().max(500)
  }),

  update: Joi.object({
    name: Joi.string().optional().min(3).max(100),
    code: Joi.string().optional().min(2).max(20),
    description: Joi.string().optional().max(500)
  })
};

export default courseSchema;
