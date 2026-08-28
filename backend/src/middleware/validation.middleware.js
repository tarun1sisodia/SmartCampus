/**
 * Zod validation middleware.
 *
 * Usage:
 *   validate(schema)             → validates req.body (default)
 *   validate(schema, 'query')    → validates req.query
 *   validate(schema, 'params')   → validates req.params
 *
 * Validated data replaces the original request property so handlers only
 * ever see sanitised values.
 */
export default (schema, source = 'body') => (req, res, next) => {
  try {
    const result = schema.parse(req[source]);
    req[source] = result;
    next();
  } catch (err) {
    const issues = err?.issues?.map((i) => ({
      path: i.path?.join('.') || source,
      message: i.message,
    }));
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: issues || [{ message: 'Invalid input' }],
    });
  }
};
