const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const backupRecordSchema = new Schema({
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation' }, // null = global
  backupType: { type: String, enum: ['full', 'incremental'], required: true },
  status: { type: String, enum: ['pending', 'completed', 'failed'], default: 'pending' },
  s3Key: { type: String },
  sizeBytes: { type: Number },
  startedAt: { type: Date },
  completedAt: { type: Date },
  triggeredBy: { type: Schema.Types.ObjectId, ref: 'User' }
}, {
  timestamps: true
});

module.exports = mongoose.model('BackupRecord', backupRecordSchema);
