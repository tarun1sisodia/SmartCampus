// =============================================================
// email.service.js  ->  ALGORITHM ONLY (source: backend/src/services/email.service.js)
// All emails go through the Bull emailQueue (never send inline in a request).
// =============================================================

// escapeHtml(value) -> escape & < > " ' before embedding user text in HTML

// sendInviteEmail(to, token, inviterName) :
//   link = FRONTEND_URL/accept-invite?token=... -> queue HTML email 'Invitation to SmartCampus'

// sendBulkEmail(recipients[], subject, html) : queue one job per recipient

// sendPasswordResetEmail(to, token) : link = FRONTEND_URL/reset-password?token=... -> queue job
