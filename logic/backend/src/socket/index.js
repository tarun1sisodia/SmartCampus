// =============================================================
// socket/index.js  ->  ALGORITHM ONLY (source: backend/src/socket/index.js)
// Socket.IO realtime channel with JWT handshake auth.
// =============================================================

// initSocket(httpServer) :
//   new Server with CORS from the same allowed-origins list as Express
//   io.use handshake middleware:
//     token = handshake.auth.token; missing -> reject 'token required'
//     verifyAccessToken -> attach socket.user { id, role, organisation }
//     (never trust a client-supplied userId — that allowed impersonation before)
//   on connection: socket.join('user:<id>')  -> personal room per user
//   on disconnect: leave the room

// emitToUser(userId, event, data) : io.to('user:<userId>').emit(...) — targeted realtime push
