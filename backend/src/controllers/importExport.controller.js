import studentService from '../services/student.service.js';
import csvParser from '../utils/csvParser.js';
import {  sendSuccess  } from '../utils/apiResponse.js';
import fs from 'fs';

export const bulkImportStudents = async (req, res, next) => {
  try {
    if (!req.file) throw Object.assign(new Error('No file uploaded'), { status: 400 });
    
    const buffer = fs.readFileSync(req.file.path);
    const parsedData = await csvParser.parseCSV(buffer);
    const result = await studentService.bulkImport(parsedData, req.scope.organisationId || req.body.organisationId, req.user.id);
    
    fs.unlinkSync(req.file.path);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export default { bulkImportStudents };
