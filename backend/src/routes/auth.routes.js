const { Router } = require('express');
const { body } = require('express-validator');
const rateLimit = require('express-rate-limit');
const validate = require('../middlewares/validate.middleware');
const authController = require('../controllers/auth.controller');

const router = Router();

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many attempts, please try again later', errors: [] },
});

router.post(
  '/register',
  authLimiter,
  [
    body('email').isEmail().withMessage('A valid email is required').normalizeEmail(),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('businessName').trim().notEmpty().withMessage('Business name is required'),
  ],
  validate,
  authController.register,
);

router.post(
  '/login',
  authLimiter,
  [
    body('email').isEmail().withMessage('A valid email is required').normalizeEmail(),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validate,
  authController.login,
);

router.post('/refresh', [body('refreshToken').notEmpty()], validate, authController.refresh);

router.post('/logout', authController.logout);

module.exports = router;
