import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const qrLogSchema = new Schema({
  session: { type: Schema.Types.ObjectId, ref: 'Session', required: true },
  teacher: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  token: { type: String, required: true },
  expiresAt: { type: Date, required: true },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true },
  timestamp: { type: Date, default: Date.now }
}, {
  timestamps: true
});

export default mongoose.model('QrLog', qrLogSchema);
