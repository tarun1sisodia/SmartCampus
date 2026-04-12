const express = require('express');
const router = express.Router();
const backupController = require('../../controllers/backup.controller');
const auth = require('../../middleware/auth.middleware');
const rbac = require('../../middleware/rbac.middleware');

router.post('/create', auth, rbac('super_admin'), backupController.create);
router.get('/list', auth, rbac('super_admin'), backupController.list);
router.post('/restore/:backupId', auth, rbac('super_admin'), backupController.restore);

module.exports = router;
