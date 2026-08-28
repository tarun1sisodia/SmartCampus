import express from 'express';
const router = express.Router();
import studentController from '../../controllers/student.controller.js';
import importExportController from '../../controllers/importExport.controller.js';
import auth from '../../middleware/auth.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';
import upload, { verifyUploadedContent } from '../../config/multer.js';
import validate from '../../middleware/validation.middleware.js';
import { createStudentSchema } from '../../validators/student.validator.js';

router.get('/', auth, orgScope, studentController.list);
router.post('/', auth, rbac('super_admin', 'org_admin'), orgScope, validate(createStudentSchema), studentController.create);
router.post('/import', auth, rbac('super_admin', 'org_admin'), orgScope, upload.single('file'), verifyUploadedContent, importExportController.bulkImportStudents);
router.get('/:id', auth, orgScope, studentController.getById);
router.put('/:id', auth, rbac('super_admin', 'org_admin'), orgScope, studentController.update);
router.delete('/:id', auth, rbac('super_admin', 'org_admin'), orgScope, studentController.delete);

router.post('/:id/photo', auth, rbac('super_admin', 'org_admin', 'teacher'), orgScope, upload.single('photo'), verifyUploadedContent, studentController.uploadPhoto);
router.delete('/:id/photo', auth, rbac('super_admin', 'org_admin', 'teacher'), orgScope, studentController.deletePhoto);

export default router;
