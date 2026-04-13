import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const feedbackSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  organisation: { type: Schema.Types.ObjectId, ref: 'Organisation' },
  rating: { type: Number, min: 1, max: 5 },
  comment: { type: String },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model('Feedback', feedbackSchema);
