import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const attendanceSchema = new Schema({
  session: { type: Schema.Types.ObjectId, ref: 'Session', required: true },
  student: { type: Schema.Types.ObjectId, ref: 'Student', required: true },
  status: { type: String, enum: ['present', 'absent', 'late', 'excused'], required: true },
  markedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  remarks: { type: String },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true },
  timestamp: { type: Date, default: Date.now }
}, {
  timestamps: true
});

attendanceSchema.index({ session: 1, student: 1 }, { unique: true });
attendanceSchema.index({ organisation: 1, student: 1 });

export default mongoose.model('Attendance', attendanceSchema);
