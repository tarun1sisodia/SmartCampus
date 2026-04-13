import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const courseSchema = new Schema({
  name: { type: String, required: true },
  code: { type: String, required: true },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation', required: true },
  durationYears: { type: Number, required: true },
  subjects: [{ type: Schema.Types.ObjectId, ref: 'Subject' }]
}, {
  timestamps: true
});

courseSchema.index({ organisation: 1, code: 1 }, { unique: true });

export default mongoose.model('Course', courseSchema);
