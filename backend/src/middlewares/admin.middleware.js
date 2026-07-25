const ApiError = require('../utils/ApiError');

/** Must run after authMiddleware — relies on req.user being set. */
function adminMiddleware(req, res, next) {
  if (!req.user || req.user.role !== 'admin') {
    throw new ApiError(403, 'Admin access required');
  }
  next();
}

module.exports = adminMiddleware;
