// =============================================================
// AuditLog.model.js  ->  ALGORITHM ONLY (source: backend/src/models/AuditLog.model.js)
// =============================================================

// schema: organisation?, user?, action ('DEACTIVATE_USER','MARK_ATTENDANCE',...),
//   entityType, entityId, oldValues, newValues (Mixed), ip, userAgent, timestamp
// written by services on every privileged action (role change, deactivate, password ops)
