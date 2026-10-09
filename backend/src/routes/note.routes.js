const { Router } = require('express');
const { body, param } = require('express-validator');
const authMiddleware = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const noteController = require('../controllers/callNote.controller');

const router = Router();

router.use(authMiddleware);

router.get('/', noteController.listNotes);

router.put(
  '/:callKey',
  [
    param('callKey').trim().notEmpty().withMessage('callKey is required'),
    body('note').optional({ nullable: true }).isString().isLength({ max: 2000 }).withMessage('Note is too long'),
    body('number').optional({ nullable: true }).isString().trim(),
    body('name').optional({ nullable: true }).isString().trim(),
  ],
  validate,
  noteController.upsertNote,
);

router.delete(
  '/:callKey',
  [param('callKey').trim().notEmpty().withMessage('callKey is required')],
  validate,
  noteController.deleteNote,
);

module.exports = router;
