const express = require('express');
const router = express.Router();
const studentController = require('../../controllers/student.controller');
const importExportController = require('../../controllers/importExport.controller');
const auth = require('../../middleware/auth.middleware');
const orgScope = require('../../middleware/orgScope.middleware');
const rbac = require('../../middleware/rbac.middleware');
const upload = require('../../config/multer');
const validate = require('../../middleware/validation.middleware');
const { createStudentSchema } = require('../../validators/student.validator');

router.get('/', auth, orgScope, studentController.list);
router.post('/', auth, rbac('super_admin', 'org_admin'), orgScope, validate(createStudentSchema), studentController.create);
router.post('/import', auth, rbac('super_admin', 'org_admin'), orgScope, upload.single('file'), importExportController.bulkImportStudents);
router.get('/:id', auth, orgScope, studentController.getById);
router.put('/:id', auth, rbac('super_admin', 'org_admin'), orgScope, studentController.update);
router.delete('/:id', auth, rbac('super_admin', 'org_admin'), orgScope, studentController.delete);

router.post('/:id/photo', auth, rbac('super_admin', 'org_admin', 'teacher'), upload.single('photo'), studentController.uploadPhoto);
router.delete('/:id/photo', auth, rbac('super_admin', 'org_admin', 'teacher'), studentController.deletePhoto);

module.exports = router;
