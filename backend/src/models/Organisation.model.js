const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const organisationSchema = new Schema({
  name: { type: String, required: true },
  type: { type: String, enum: ['school', 'college'], required: true },
  domain: { type: String, sparse: true, unique: true },
  address: { type: String },
  contactEmail: { type: String },
  contactPhone: { type: String },
  subscription: {
    plan: { type: String, enum: ['free', 'premium', 'enterprise'], default: 'free' },
    validUntil: { type: Date },
    maxTeachers: { type: Number, default: 10 },
    maxStudents: { type: Number, default: 500 }
  },
  status: { type: String, enum: ['active', 'suspended', 'trial'], default: 'trial' },
  createdBy: { type: Schema.Types.ObjectId, ref: 'User' },
}, { 
  timestamps: true 
});

organisationSchema.index({ domain: 1 });
organisationSchema.index({ status: 1 });

module.exports = mongoose.model('Organisation', organisationSchema);
