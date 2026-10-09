const { Router } = require('express');
const { body, param } = require('express-validator');
const authMiddleware = require('../middlewares/auth.middleware');
const adminMiddleware = require('../middlewares/admin.middleware');
const validate = require('../middlewares/validate.middleware');
const adminController = require('../controllers/admin.controller');
const contactController = require('../controllers/contact.controller');

const router = Router();

router.use(authMiddleware, adminMiddleware);

router.get('/users', adminController.listUsers);

router.get('/users/:id', [param('id').isMongoId()], validate, adminController.getUser);

router.patch(
  '/users/:id',
  [
    param('id').isMongoId(),
    body('subscriptionPlan').optional().isIn(['free', 'pro']),
    body('isActive').optional().isBoolean(),
  ],
  validate,
  adminController.updateUser,
);

router.get('/stats', adminController.getStats);

router.get('/leads', adminController.listLeads);

router.get('/contacts', contactController.listMessages);

router.get('/contacts/:id', [param('id').isMongoId()], validate, contactController.getMessage);

router.patch(
  '/contacts/:id',
  [param('id').isMongoId(), body('status').isIn(['new', 'resolved'])],
  validate,
  contactController.updateMessageStatus,
);

module.exports = router;
