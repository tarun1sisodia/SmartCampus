import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const refreshTokenSchema = new Schema({
  token: { type: String, required: true },
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  expiresAt: { type: Date, required: true }
}, {
  timestamps: true
});

refreshTokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export default mongoose.model('RefreshToken', refreshTokenSchema);
