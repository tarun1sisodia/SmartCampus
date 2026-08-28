import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const refreshTokenSchema = new Schema(
  {
    // sha256 hash of the refresh token — the raw token is never persisted.
    tokenHash: { type: String, required: true },
    user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true }
);

refreshTokenSchema.index({ tokenHash: 1 }, { unique: true });
refreshTokenSchema.index({ user: 1 });
refreshTokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export default mongoose.model('RefreshToken', refreshTokenSchema);
