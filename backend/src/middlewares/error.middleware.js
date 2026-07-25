const ApiError = require('../utils/ApiError');

function errorMiddleware(err, req, res, next) {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.errors,
    });
  }

  // Mongoose duplicate key error (e.g. email already registered)
  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern || {})[0] || 'field';
    return res.status(409).json({
      success: false,
      message: `${field} already in use`,
      errors: [],
    });
  }

  console.error('[error]', err);
  return res.status(500).json({
    success: false,
    message: 'Internal server error',
    errors: [],
  });
}

module.exports = errorMiddleware;
