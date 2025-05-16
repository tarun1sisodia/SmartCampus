import request from 'supertest';
import app from '../index';

describe('App', () => {
  it('should respond to health check', async () => {
    const response = await request(app).get('/api/v1/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('success');
  });
});
