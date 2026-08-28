import studentService from '../services/student.service.js';
import csvParser from '../utils/csvParser.js';
import { sendSuccess } from '../utils/apiResponse.js';

export const bulkImportStudents = async (req, res, next) => {
  try {
    if (!req.file) throw Object.assign(new Error('No file uploaded'), { status: 400 });

    // Multer is configured with memory storage; no temp files to clean up.
    const buffer = req.file.buffer;
    if (!buffer?.length) throw Object.assign(new Error('Uploaded file is empty'), { status: 400 });

    const parsedData = await csvParser.parseCSV(buffer);
    const result = await studentService.bulkImport(parsedData, req.scope.organisationId || req.body.organisationId, req.user.id);

    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export default { bulkImportStudents };
