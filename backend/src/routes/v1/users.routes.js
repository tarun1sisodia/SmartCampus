const express = require('express');
const router = express.Router();
const userController = require('../../controllers/user.controller');
const auth = require('../../middleware/auth.middleware');
const rbac = require('../../middleware/rbac.middleware');
const orgScope = require('../../middleware/orgScope.middleware');
const validate = require('../../middleware/validation.middleware');
const upload = require('../../config/multer');
const { inviteSchema, acceptInviteSchema } = require('../../validators/auth.validator');
const { changePasswordSchema } = require('../../validators/auth.validator');

router.post('/invite', auth, rbac('super_admin', 'org_admin'), orgScope, validate(inviteSchema), userController.sendInvite);
router.post('/accept-invite', validate(acceptInviteSchema), userController.acceptInvite);
router.post('/:userId/resend', auth, rbac('super_admin', 'org_admin'), orgScope, userController.resendInvite);
router.get('/teachers', auth, rbac('super_admin', 'org_admin'), orgScope, userController.listTeachers);
router.delete('/:userId', auth, rbac('super_admin', 'org_admin'), orgScope, userController.deactivate);

router.post('/change-password', auth, validate(changePasswordSchema), userController.changePassword);
router.post('/me/photo', auth, upload.single('photo'), userController.uploadProfilePhoto);
router.delete('/me/photo', auth, userController.deleteProfilePhoto);

module.exports = router;
