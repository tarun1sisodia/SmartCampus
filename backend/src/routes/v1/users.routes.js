import express from 'express';
const router = express.Router();
import userController from '../../controllers/user.controller.js';
import auth from '../../middleware/auth.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';
import validate from '../../middleware/validation.middleware.js';
import upload from '../../config/multer.js';
import {  inviteSchema, acceptInviteSchema  } from '../../validators/auth.validator.js';
import {  changePasswordSchema  } from '../../validators/auth.validator.js';

router.post('/invite', auth, rbac('super_admin', 'org_admin'), orgScope, validate(inviteSchema), userController.sendInvite);
router.post('/accept-invite', validate(acceptInviteSchema), userController.acceptInvite);
router.post('/:userId/resend', auth, rbac('super_admin', 'org_admin'), orgScope, userController.resendInvite);
router.get('/teachers', auth, rbac('super_admin', 'org_admin'), orgScope, userController.listTeachers);
router.delete('/:userId', auth, rbac('super_admin', 'org_admin'), orgScope, userController.deactivate);

router.get('/me', auth, userController.getMe);
router.post('/change-password', auth, validate(changePasswordSchema), userController.changePassword);
router.post('/me/photo', auth, upload.single('photo'), userController.uploadProfilePhoto);
router.delete('/me/photo', auth, userController.deleteProfilePhoto);

export default router;
