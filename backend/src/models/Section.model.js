const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const sectionSchema = new Schema({
  name: { type: String, required: true },
  course: { type: Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Schema.Types.ObjectId, ref: 'Semester', required: true },
  classTeacher: { type: Schema.Types.ObjectId, ref: 'User' },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true }
}, {
  timestamps: true
});

module.exports = mongoose.model('Section', sectionSchema);
