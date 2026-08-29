// =============================================================
// email.worker.js  ->  ALGORITHM ONLY (source: backend/src/workers/email.worker.js)
// =============================================================

// setupEmailWorker() :
//   nodemailer transporter from SMTP env (host/port 465 secure/user/pass)
//   emailQueue.process(job { to, subject, html }) :
//     sendMail -> log message id (ethereal test url when testing) ; failure -> throw (bull retries 3x)
