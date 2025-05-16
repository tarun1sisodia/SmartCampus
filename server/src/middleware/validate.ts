import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { BadRequestError } from '../utils/error';

export const validate = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, { abortEarly: false });
    
    if (error) {
      const errorMessage = error.details
        .map((detail) => detail.message)
        .join(', ');
      throw new BadRequestError(errorMessage);
    }
    
    next();
  };
};

export default validate;
