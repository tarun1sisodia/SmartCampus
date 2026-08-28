import { Server } from 'socket.io';
import { verifyAccessToken } from '../utils/generateToken.js';
import logger from '../config/logger.js';

let io;

export const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: [
        'http://localhost:3000',
        'http://localhost:3001',
        ...(process.env.FRONTEND_URL ? process.env.FRONTEND_URL.split(',').map((o) => o.trim()) : []),
      ].filter(Boolean),
      credentials: true
    }
  });

  io.use((socket, next) => {
    // Require a signed JWT on the handshake. Previously any caller-supplied
    // userId was trusted, allowing full impersonation of the realtime channel.
    const token = socket.handshake.auth?.token;
    if (!token) {
      return next(new Error('Authentication error: token required'));
    }
    try {
      const decoded = verifyAccessToken(token);
      socket.user = {
        id: decoded.sub,
        role: decoded.role,
        organisation: decoded.org,
      };
      next();
    } catch (err) {
      next(new Error('Authentication error: invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.user.id;
    socket.join(`user:${userId}`);

    socket.on('disconnect', () => {
      socket.leave(`user:${userId}`);
    });
  });

  logger.info('Socket.IO initialised with JWT handshake authentication');
  return io;
};

export const emitToUser = (userId, event, data) => {
  if (io) {
    io.to(`user:${userId}`).emit(event, data);
  }
};

export default { initSocket, emitToUser };
