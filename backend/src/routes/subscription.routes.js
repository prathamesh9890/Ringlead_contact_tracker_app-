const { Router } = require('express');
const { body } = require('express-validator');
const authMiddleware = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const subscriptionController = require('../controllers/subscription.controller');

const router = Router();

router.use(authMiddleware);

router.get('/me', subscriptionController.getMine);

router.patch(
  '/me',
  [body('plan').isIn(['free', 'pro']).withMessage('plan must be "free" or "pro"')],
  validate,
  subscriptionController.updateMine,
);

module.exports = router;
