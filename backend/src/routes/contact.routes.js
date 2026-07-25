const { Router } = require('express');
const { body } = require('express-validator');
const rateLimit = require('express-rate-limit');
const validate = require('../middlewares/validate.middleware');
const contactController = require('../controllers/contact.controller');

const router = Router();

const contactLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many messages sent, please try again later', errors: [] },
});

router.post(
  '/',
  contactLimiter,
  [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('A valid email is required').normalizeEmail(),
    body('message').trim().isLength({ min: 5 }).withMessage('Message must be at least 5 characters'),
  ],
  validate,
  contactController.submit,
);

module.exports = router;
