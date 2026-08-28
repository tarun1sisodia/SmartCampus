import express from 'express';
const router = express.Router();
import userController from '../../controllers/user.controller.js';
import auth from '../../middleware/auth.middleware.js';
import rbac from '../../middleware/rbac.middleware.js';
import orgScope from '../../middleware/orgScope.middleware.js';
import validate from '../../middleware/validation.middleware.js';
import rateLimiters from '../../middleware/rateLimiter.js';
import upload from '../../config/multer.js';
import {
  inviteSchema,
  acceptInviteSchema,
  changePasswordSchema,
  updateProfileSchema,
  updateRoleSchema,
} from '../../validators/auth.validator.js';

router.post('/invite', auth, rbac('super_admin', 'org_admin'), orgScope, validate(inviteSchema), userController.sendInvite);
router.post('/accept-invite', rateLimiters.sensitiveLimiter, validate(acceptInviteSchema), userController.acceptInvite);
// Both aliases supported: the portal calls /resend-invite, legacy callers /resend.
router.post('/:userId/resend', auth, rbac('super_admin', 'org_admin'), orgScope, userController.resendInvite);
router.post('/:userId/resend-invite', auth, rbac('super_admin', 'org_admin'), orgScope, userController.resendInvite);
router.get('/teachers', auth, rbac('super_admin', 'org_admin'), orgScope, userController.listTeachers);
router.delete('/:userId', auth, rbac('super_admin', 'org_admin'), orgScope, userController.deactivate);

// Super-admin portal: full user directory, role management, admin reset.
router.get('/', auth, rbac('super_admin'), orgScope, userController.listUsers);
router.patch('/:userId', auth, rbac('super_admin'), orgScope, validate(updateRoleSchema), userController.updateUserRole);
router.post('/:userId/reset-password', auth, rbac('super_admin', 'org_admin'), orgScope, rateLimiters.sensitiveLimiter, userController.adminResetPassword);

router.get('/me', auth, userController.getMe);
router.patch('/me', auth, validate(updateProfileSchema), userController.updateMe);
router.post('/change-password', auth, rateLimiters.sensitiveLimiter, validate(changePasswordSchema), userController.changePassword);
router.post('/me/photo', auth, upload.single('photo'), userController.uploadProfilePhoto);
router.delete('/me/photo', auth, userController.deleteProfilePhoto);

export default router;
