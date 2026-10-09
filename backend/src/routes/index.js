const { Router } = require('express');
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
const subscriptionRoutes = require('./subscription.routes');
const adminRoutes = require('./admin.routes');
const contactRoutes = require('./contact.routes');
const noteRoutes = require('./note.routes');

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/subscription', subscriptionRoutes);
router.use('/admin', adminRoutes);
router.use('/contact', contactRoutes);
router.use('/notes', noteRoutes);

module.exports = router;
