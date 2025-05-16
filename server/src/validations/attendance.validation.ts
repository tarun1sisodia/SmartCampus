import Joi from 'joi';
import { AttendanceStatus } from '../types';

export const attendanceSchema = {
  createSession: Joi.object({
    subject_id: Joi.string().uuid().required(),
    teacher_id: Joi.string().uuid().required(),
    date: Joi.date().required(),
    start_time: Joi.date().required(),
    end_time: Joi.date().required().greater(Joi.ref('start_time'))
  }),

  markAttendance: Joi.object({
    status: Joi.string()
      .valid(...Object.values(AttendanceStatus))
      .required()
  }),

  dateRange: Joi.object({
    startDate: Joi.date().optional(),
    endDate: Joi.date()
      .optional()
      .when('startDate', {
        is: Joi.exist(),
        then: Joi.date().greater(Joi.ref('startDate'))
      })
  })
};

export default attendanceSchema;
