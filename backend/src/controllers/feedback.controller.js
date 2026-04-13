const Feedback = require('../models/Feedback.model');
const { sendSuccess } = require('../utils/apiResponse');

exports.submit = async (req, res, next) => {
  try {
    const { rating, comment } = req.body;
    await Feedback.create({
      user: req.user.id,
      rating,
      comment,
      organisation: req.scope ? req.scope.organisationId : req.user.organisation
    });
    sendSuccess(res, { success: true });
  } catch (err) {
    next(err);
  }
};
