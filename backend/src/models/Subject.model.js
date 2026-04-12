const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const subjectSchema = new Schema({
  name: { type: String, required: true },
  code: { type: String, required: true },
  credits: { type: Number, default: 3 },
  course: { type: Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Number, required: true }, // 1, 2, 3, etc.
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true }
}, {
  timestamps: true
});

module.exports = mongoose.model('Subject', subjectSchema);
