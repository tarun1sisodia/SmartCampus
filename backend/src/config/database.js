const mongoose = require('mongoose');
const logger = require('./logger');

const connectDB = async () => {
  try {
    const uri = process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus';
    const options = {
      // These are no longer needed in Mongoose 6+, but included for completeness if using older Mongoose
      // useNewUrlParser: true,
      // useUnifiedTopology: true,
    };
    await mongoose.connect(uri, options);
    logger.info('MongoDB connected successfully');
  } catch (error) {
    logger.error(`MongoDB connection error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
