const express = require('express');
const router = express.Router();
const orgController = require('../../controllers/organisation.controller');
const auth = require('../../middleware/auth.middleware');
const rbac = require('../../middleware/rbac.middleware');
const validate = require('../../middleware/validation.middleware');
const { createOrgSchema } = require('../../validators/org.validator');

router.post('/', auth, rbac('super_admin'), validate(createOrgSchema), orgController.create);
router.get('/', auth, rbac('super_admin'), orgController.list);
router.get('/:orgId', auth, rbac('super_admin'), orgController.get);
router.patch('/:orgId', auth, rbac('super_admin'), orgController.update);

module.exports = router;
