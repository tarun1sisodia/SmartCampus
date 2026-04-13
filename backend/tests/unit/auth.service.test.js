const authService = require('../../src/services/auth.service');
const User = require('../../src/models/User.model');
const RefreshToken = require('../../src/models/RefreshToken.model');
const bcrypt = require('bcrypt');

jest.mock('../../src/models/User.model');
jest.mock('../../src/models/RefreshToken.model');
jest.mock('bcrypt');

describe('Auth Service Unit Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('login()', () => {
    it('should return tokens and user info when credentials are correct', async () => {
      // Arrange
      const mockUser = {
        _id: 'user123',
        role: 'teacher',
        organisation: 'org123',
        password: 'hashedPassword',
        isActive: true,
        save: jest.fn(),
        toJSON: jest.fn().mockReturnValue({ _id: 'user123', role: 'teacher', email: 'test@example.com' })
      };
      
      User.findOne.mockReturnValue({
        select: jest.fn().mockResolvedValue(mockUser)
      });
      
      bcrypt.compare.mockResolvedValue(true); // Password match
      bcrypt.hash.mockResolvedValue('hashedRefreshToken');
      RefreshToken.create.mockResolvedValue({});

      // Act
      const result = await authService.login('test@example.com', 'password123');

      // Assert
      expect(User.findOne).toHaveBeenCalledWith({ email: 'test@example.com', isActive: true });
      expect(bcrypt.compare).toHaveBeenCalledWith('password123', 'hashedPassword');
      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result.user).toEqual({ _id: 'user123', role: 'teacher', email: 'test@example.com' });
      expect(mockUser.save).toHaveBeenCalled(); // lastLogin updated
    });

    it('should throw an error if user is not found', async () => {
      // Arrange
      User.findOne.mockReturnValue({
        select: jest.fn().mockResolvedValue(null)
      });

      // Act & Assert
      await expect(authService.login('wrong@example.com', 'pass')).rejects.toThrow('Invalid credentials');
    });

    it('should throw an error with incorrect password', async () => {
      // Arrange
      const mockUser = { email: 'test@example.com', password: 'hashedPassword' };
      User.findOne.mockReturnValue({
        select: jest.fn().mockResolvedValue(mockUser)
      });
      bcrypt.compare.mockResolvedValue(false); // Password mismatch

      // Act & Assert
      await expect(authService.login('test@example.com', 'wrongpass')).rejects.toThrow('Invalid credentials');
    });
  });

  describe('refreshAccessToken()', () => {
    it('should throw error if token is missing or invalid payload', async () => {
      await expect(authService.refreshAccessToken('invalid-token')).rejects.toThrow();
    });
  });
});
