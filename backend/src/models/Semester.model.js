import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const semesterSchema = new Schema({
  name: { type: String, required: true },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  isActive: { type: Boolean, default: true },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true }
}, {
  timestamps: true
});

export default mongoose.model('Semester', semesterSchema);
