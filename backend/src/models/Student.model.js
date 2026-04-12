const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const studentSchema = new Schema({
  rollNumber: { type: String, required: true },
  name: { type: String, required: true },
  email: { type: String },
  photo: { type: String },
  course: { type: Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Schema.Types.ObjectId, ref: 'Semester', required: true },
  section: { type: Schema.Types.ObjectId, ref: 'Section', required: true },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true },
  enrollmentYear: { type: Number },
  contact: { type: String },
  parentContact: { type: String },
  address: { type: String },
  isActive: { type: Boolean, default: true }
}, {
  timestamps: true
});

studentSchema.index({ organisation: 1, rollNumber: 1 }, { unique: true });
studentSchema.index({ organisation: 1, course: 1 });

module.exports = mongoose.model('Student', studentSchema);
