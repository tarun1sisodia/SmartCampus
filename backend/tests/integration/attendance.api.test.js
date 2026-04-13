const request = require('supertest');
const app = require('../../src/app');
const mongoose = require('mongoose');

// We use jest.mock to mock out the underlying service rather than hitting a real DB in this layer, 
// to ensure rapid integration testing of the API boundaries.
jest.mock('../../src/services/attendance.service');
const attendanceService = require('../../src/services/attendance.service');

// Mock Auth middleware to bypass real JWT checking and inject a valid req.user
jest.mock('../../src/middleware/auth.middleware', () => {
  return (req, res, next) => {
    req.user = { id: 'teacher123', role: 'teacher', organisation: 'org123' };
    next();
  };
});

describe('Attendance API Integration Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('POST /api/v1/attendance/mark -> marks attendance securely', async () => {
    attendanceService.markBulk.mockResolvedValue({ updatedCount: 2 });
    
    // We send an Object that matches Zod's markAttendanceSchema constraints
    const payload = {
      sessionId: new mongoose.Types.ObjectId().toHexString(),
      attendance: [
        { studentId: new mongoose.Types.ObjectId().toHexString(), status: 'present' },
        { studentId: new mongoose.Types.ObjectId().toHexString(), status: 'absent' }
      ]
    };

    const res = await request(app)
      .post('/api/v1/attendance/mark')
      .send(payload)
      .expect(200);

    expect(res.body.success).toBe(true);
    expect(res.body.data.updatedCount).toBe(2);
    expect(attendanceService.markBulk).toHaveBeenCalledTimes(1);
    // Verifies req.user constraints were passed via router properly to the service
    expect(attendanceService.markBulk).toHaveBeenCalledWith(
      payload.sessionId, 
      payload.attendance, 
      'teacher123', // teacher ID from mocked JWT
      'org123',     // org ID from mocked JWT scope translation
      false         // isSuperAdmin = false
    );
  });

  it('POST /api/v1/attendance/mark -> fails on invalid validation schema', async () => {
    const payload = {
      // missing sessionId
      attendance: [
        { studentId: 'not-an-object-id', status: 'invalid_status' }
      ]
    };

    const res = await request(app)
      .post('/api/v1/attendance/mark')
      .send(payload)
      .expect(400);

    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Validation failed');
  });
});
