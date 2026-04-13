import express from 'express';
const router = express.Router();
import orgController from '../../controllers/organisation.controller.js';
import auth from '../../middleware/auth.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';
import validate from '../../middleware/validation.middleware.js';
import {  createOrgSchema  } from '../../validators/org.validator.js';

router.post('/', auth, rbac('super_admin'), validate(createOrgSchema), orgController.create);
router.get('/', auth, rbac('super_admin'), orgController.list);
router.get('/:orgId', auth, rbac('super_admin'), orgController.get);
router.patch('/:orgId', auth, rbac('super_admin'), orgController.update);

export default router;
