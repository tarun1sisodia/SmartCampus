import { Router } from 'express';
import AuthController from '../controllers/auth.controller';
import { authenticateToken } from '../middleware/auth';

const router = Router();

router.post('/signup', AuthController.signup);
router.post('/login', AuthController.login);
router.post('/logout', authenticateToken, AuthController.logout);

export default router;
