import crypto from 'crypto';

const SECRET_KEY = process.env.QR_SECRET_KEY || 'super_secret_attendance_salt';

class QrService {
  /**
   * Generates a time-based HMAC token for a given session.
   * Uses 15-second intervals similar to TOTP.
   */
  generateToken(sessionId) {
    const timeSlot = Math.floor(Date.now() / 15000);
    const data = `${sessionId}:${timeSlot}`;
    return crypto.createHmac('sha256', SECRET_KEY).update(data).digest('hex').substring(0, 12);
  }

  /**
   * Validates a token against the current or immediately previous 15-second time slot.
   */
  validateToken(token, sessionId) {
    const currentSlot = Math.floor(Date.now() / 15000);
    const data1 = `${sessionId}:${currentSlot}`;
    const data2 = `${sessionId}:${currentSlot - 1}`;
    
    const token1 = crypto.createHmac('sha256', SECRET_KEY).update(data1).digest('hex').substring(0, 12);
    const token2 = crypto.createHmac('sha256', SECRET_KEY).update(data2).digest('hex').substring(0, 12);
    
    return token === token1 || token === token2;
  }
}

export default new QrService();
