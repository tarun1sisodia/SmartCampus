import mongoose from 'mongoose';
const Schema = mongoose.Schema;

// CQRS read model (Materialized View)
const attendanceSummarySchema = new Schema({
  student: { type: Schema.Types.ObjectId, ref: 'Student', required: true },
  session: { type: Schema.Types.ObjectId, ref: 'Session', required: true },
  course: { type: Schema.Types.ObjectId, ref: 'Course', required: true },
  subject: { type: Schema.Types.ObjectId, ref: 'Subject', required: true },
  semester: { type: Schema.Types.ObjectId, ref: 'Semester', required: true },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true },
  date: { type: Date, required: true },
  status: { type: String, enum: ['present', 'absent', 'late', 'excused'], required: true },
  // pre-joined fields for fast querying
  studentName: { type: String },
  rollNumber: { type: String }
}, {
  timestamps: true
});

attendanceSummarySchema.index({ organisation: 1, student: 1, semester: 1 });
// Ensure we don't have duplicates for the same student returning for the same session
attendanceSummarySchema.index({ session: 1, student: 1 }, { unique: true });

export default mongoose.model('AttendanceSummary', attendanceSummarySchema);
