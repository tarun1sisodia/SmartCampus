import crypto from 'crypto';

const SECRET_KEY = process.env.QR_SECRET_KEY || undefined;

class QrService {
  /**
   * Generates a time-based HMAC token for a given session.
   * Uses 15-second intervals similar to TOTP.
   * Token is 16 hex chars (64 bits) — long enough to resist on-screen
   * shoulder-surfing brute force within a rotation window.
   */
  generateToken(sessionId) {
    const timeSlot = this.currentSlot();
    const data = `${sessionId}:${timeSlot}`;
    return crypto.createHmac('sha256', this.secret()).update(data).digest('hex').substring(0, 16);
  }

  /**
   * Validates a token against the current or immediately previous 15-second
   * time slot (tolerates a scan right at the rotation boundary).
   */
  validateToken(token, sessionId) {
    if (typeof token !== 'string' || token.length !== 16) return false;
    const currentSlot = this.currentSlot();
    const prev = this.tokenForSlot(sessionId, currentSlot - 1);
    if (prev && crypto.timingSafeEqual(Buffer.from(prev), Buffer.from(token))) return true;
    const curr = this.tokenForSlot(sessionId, currentSlot);
    return !!curr && crypto.timingSafeEqual(Buffer.from(curr), Buffer.from(token));
  }

  tokenForSlot(sessionId, slot) {
    const data = `${sessionId}:${slot}`;
    return crypto.createHmac('sha256', this.secret()).update(data).digest('hex').substring(0, 16);
  }

  currentSlot() {
    return Math.floor(Date.now() / 15000);
  }

  secret() {
    // env.js validates QR_SECRET_KEY in production; dev fallback kept local.
    return SECRET_KEY || 'dev-qr-secret-please-override';
  }

  secondsUntilNextSlot() {
    return 15 - Math.floor((Date.now() / 1000) % 15);
  }
}

export default new QrService();
