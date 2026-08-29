// =============================================================
// server.js  ->  ALGORITHM ONLY (source: backend/server.js)
// Backend entry point (Node + Express + MongoDB + Redis + Socket.IO).
// =============================================================

// import env config FIRST (populates process.env + fail-fast validation before anything else)
// import app, connectDB, logger, initSocket, verifyExternalConnections (smoke test)
// import event subscribers + background jobs: updateAnalytics, sendNotification,
//        setupDailyBackup, setupSendReminders, setupEmailWorker

// startServer() :
//   await verifyExternalConnections()  -> pre-flight check of mongo/redis/cloudinary before booting
//   await connectDB()                  -> mongoose connects (exit 1 on failure)
//   app.listen(PORT default 5000) :
//     log "running in NODE_ENV on port"
//     AFTER the server is up, init background routines (each in try-catch so one bad job never kills boot):
//       updateAnalyticsSubscriber.setup() + sendNotificationSubscriber.setup()
//       setupDailyBackup() + setupSendReminders() + setupEmailWorker()
//   initSocket(server) -> Socket.IO on the same HTTP server (JWT-authenticated handshake)
//   on SIGTERM -> graceful shutdown: server.close() then exit(0)
//   any startup error -> log + process.exit(1)
