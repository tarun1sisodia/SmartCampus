const request = require('supertest');
const app = require('../../src/app');
const authService = require('../../src/services/auth.service');
const { createStudentSchema } = require('../../src/validators/student.validator');

// We intercept the internal core business logic directly so we don't connect to Mongoose,
// keeping our Supertest API endpoints fast and resilient.
jest.mock('../../src/services/auth.service');

describe('Auth API JWT Issuance Tests', () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /api/v1/auth/login', () => {
    
    it('Should return 200 and issue strict HTTP-Only secure cookies alongside JWT access tokens', async () => {
      // Mocking the successful service resolving to fake auth keys
      authService.login.mockResolvedValue({
        accessToken: 'mock_jwt_access_super_secure',
        refreshToken: 'mock_jwt_refresh_cookie_hash',
        user: { _id: 'fakeID123', email: 'tarun1sisodia@gmail.com', role: 'super_admin' }
      });

      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'tarun1sisodia@gmail.com',
          password: 'super_secure_mock_password'
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.accessToken).toBe('mock_jwt_access_super_secure');
      expect(response.body.data.user.role).toBe('super_admin');
      
      // Confirm that the Set-Cookie HTTP header was formulated directly by the Auth Controller
      const cookieHeader = response.headers['set-cookie'][0];
      expect(cookieHeader).toMatch(/refreshToken=mock_jwt_refresh_cookie_hash/);
      expect(cookieHeader).toMatch(/HttpOnly/);
      expect(cookieHeader).toMatch(/SameSite=Strict/);
    });

    it('Should intercept invalid Zod parameters cleanly returning an array of strict 400 validations', async () => {
      // By sending an invalid email definition, Zod in the middleware should intercept before authService is hit!
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'not-a-valid-email', 
          password: 'p' // too short
        })
        .expect(400);
      
      expect(response.body.success).toBe(false);
      expect(authService.login).not.toHaveBeenCalled(); // We caught the intruder at the API boundary!
    });
    
  });
});
