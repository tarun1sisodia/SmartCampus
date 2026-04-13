import {  Server  } from 'socket.io';

let io;

export const initSocket = (server) => {
  io = new Server(server, { 
    cors: { origin: process.env.FRONTEND_URL || '*' } 
  });
  
  io.use((socket, next) => {
    // In production, verify JWT token from socket.handshake.auth.token
    // For now we assume a user ID is passed
    const userId = socket.handshake.auth.userId;
    if (!userId) {
      return next(new Error('Authentication error'));
    }
    socket.user = { id: userId };
    next();
  });
  
  io.on('connection', (socket) => {
    const userId = socket.user.id;
    socket.join(`user:${userId}`);
    
    socket.on('disconnect', () => {
      socket.leave(`user:${userId}`);
    });
  });
  
  return io;
};

export const emitToUser = (userId, event, data) => {
  if (io) {
    io.to(`user:${userId}`).emit(event, data);
  }
};

export default { initSocket, emitToUser };
