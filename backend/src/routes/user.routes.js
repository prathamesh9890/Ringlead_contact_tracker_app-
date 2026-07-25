const { Router } = require('express');
const { body } = require('express-validator');
const authMiddleware = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const userController = require('../controllers/user.controller');

const router = Router();

router.use(authMiddleware);

router.get('/me', userController.getMe);

router.patch(
  '/me',
  [
    body('businessName').optional().trim().notEmpty().withMessage('businessName cannot be empty'),
    body('phone').optional().trim(),
  ],
  validate,
  userController.updateMe,
);

module.exports = router;
