const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const sessionSchema = new Schema({
  subject: { type: Schema.Types.ObjectId, ref: 'Subject', required: true },
  course: { type: Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Schema.Types.ObjectId, ref: 'Semester', required: true },
  section: { type: Schema.Types.ObjectId, ref: 'Section', required: true },
  teacher: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  startTime: { type: String }, // e.g. "09:00"
  endTime: { type: String }, // e.g. "10:00"
  topic: { type: String },
  isHoliday: { type: Boolean, default: false },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true }
}, {
  timestamps: true
});

module.exports = mongoose.model('Session', sessionSchema);
