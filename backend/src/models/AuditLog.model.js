const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const auditLogSchema = new Schema({
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation' },
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  action: { type: String, required: true }, // e.g., "DELETE_STUDENT", "MARK_ATTENDANCE"
  entityType: { type: String }, // "Student", "Attendance", etc.
  entityId: { type: Schema.Types.ObjectId },
  oldValues: { type: Schema.Types.Mixed },
  newValues: { type: Schema.Types.Mixed },
  ip: { type: String },
  userAgent: { type: String },
  timestamp: { type: Date, default: Date.now }
}, {
  timestamps: false // we use timestamp field manually
});

module.exports = mongoose.model('AuditLog', auditLogSchema);
