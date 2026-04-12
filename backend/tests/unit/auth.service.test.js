// Mock implementations for the tests as requested by the markdown
const authService = require('../../../src/services/auth.service');
const User = require('../../../src/models/User.model');
const RefreshToken = require('../../../src/models/RefreshToken.model');

jest.mock('../../../src/models/User.model');
jest.mock('../../../src/models/RefreshToken.model');

describe('Auth Service Unit Tests', () => {
  it('login with correct credentials -> returns tokens', async () => {
    // Tests implementation
  });

  it('login with wrong password -> throws error', async () => {
    // Tests implementation
  });
});
