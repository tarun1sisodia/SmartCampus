import express from 'express';
const router = express.Router();
import backupController from '../../controllers/backup.controller.js';
import auth from '../../middleware/auth.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';

router.post('/create', auth, rbac('super_admin'), backupController.create);
router.get('/list', auth, rbac('super_admin'), backupController.list);
router.post('/restore/:backupId', auth, rbac('super_admin'), backupController.restore);

export default router;
