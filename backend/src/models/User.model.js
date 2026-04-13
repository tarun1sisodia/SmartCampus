const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const Schema = mongoose.Schema;

const userSchema = new Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, select: false },
  role: { type: String, enum: ['super_admin', 'org_admin', 'teacher'], required: true },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation' },
  invitedBy: { type: Schema.Types.ObjectId, ref: 'User' },
  inviteToken: { type: String },
  inviteExpires: { type: Date },
  resetPasswordToken: { type: String },
  resetPasswordExpires: { type: Date },
  avatar: { type: String },
  fcmTokens: [{
    token: { type: String },
    deviceId: { type: String },
    createdAt: { type: Date, default: Date.now }
  }],
  isActive: { type: Boolean, default: false },
  lastLogin: { type: Date },
  permissions: [{ type: String }],
}, {
  timestamps: true
});

userSchema.pre('save', async function(next) {
  if (this.isModified('password') && this.password) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

userSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.password;
  delete obj.inviteToken;
  return obj;
};

userSchema.index({ email: 1 }, { unique: true });
userSchema.index({ organisation: 1, role: 1 });

module.exports = mongoose.model('User', userSchema);
