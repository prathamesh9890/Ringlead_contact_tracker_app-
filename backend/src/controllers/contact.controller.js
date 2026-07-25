const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const ApiResponse = require('../utils/ApiResponse');
const ContactMessage = require('../models/contactMessage.model');

// Public — POST /api/contact
const submit = asyncHandler(async (req, res) => {
  const { name, email, message } = req.body;
  const contactMessage = await ContactMessage.create({ name, email, message });
  res.status(201).json(new ApiResponse(201, contactMessage.toPublicProfile(), 'Message received'));
});

// Admin — GET /api/admin/contacts
const listMessages = asyncHandler(async (req, res) => {
  const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
  const limit = Math.min(parseInt(req.query.limit, 10) || 20, 100);
  const { status } = req.query;

  const filter = ['new', 'resolved'].includes(status) ? { status } : {};

  const [messages, total] = await Promise.all([
    ContactMessage.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit),
    ContactMessage.countDocuments(filter),
  ]);

  res.status(200).json(
    new ApiResponse(200, {
      messages: messages.map((m) => m.toPublicProfile()),
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    }),
  );
});

// Admin — GET /api/admin/contacts/:id
const getMessage = asyncHandler(async (req, res) => {
  const message = await ContactMessage.findById(req.params.id);
  if (!message) throw new ApiError(404, 'Message not found');
  res.status(200).json(new ApiResponse(200, message.toPublicProfile()));
});

// Admin — PATCH /api/admin/contacts/:id
const updateMessageStatus = asyncHandler(async (req, res) => {
  const message = await ContactMessage.findById(req.params.id);
  if (!message) throw new ApiError(404, 'Message not found');
  message.status = req.body.status;
  await message.save();
  res.status(200).json(new ApiResponse(200, message.toPublicProfile(), 'Message updated'));
});

module.exports = { submit, listMessages, getMessage, updateMessageStatus };
