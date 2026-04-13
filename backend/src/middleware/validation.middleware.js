export default (schema) => (req, res, next) => {
  try {
    // Only pass req properties so no implicit coercion breaks things unless specified in schema
    schema.parse(req.body);
    next();
  } catch (err) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: err.errors
    });
  }
};
