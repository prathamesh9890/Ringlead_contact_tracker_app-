const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const ApiResponse = require('../utils/ApiResponse');
const User = require('../models/user.model');
const ContactMessage = require('../models/contactMessage.model');
const CallNote = require('../models/callNote.model');

const listUsers = asyncHandler(async (req, res) => {
  const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
  const limit = Math.min(parseInt(req.query.limit, 10) || 20, 100);
  const search = (req.query.search || '').trim();

  const filter = search
    ? {
        $or: [
          { email: new RegExp(search, 'i') },
          { businessName: new RegExp(search, 'i') },
        ],
      }
    : {};

  const [users, total] = await Promise.all([
    User.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit),
    User.countDocuments(filter),
  ]);

  res.status(200).json(
    new ApiResponse(200, {
      users: users.map((u) => u.toPublicProfile()),
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    }),
  );
});

const getUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) throw new ApiError(404, 'User not found');
  res.status(200).json(new ApiResponse(200, user.toPublicProfile()));
});

const updateUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) throw new ApiError(404, 'User not found');

  const { subscriptionPlan, isActive } = req.body;
  if (subscriptionPlan !== undefined) user.subscriptionPlan = subscriptionPlan;
  if (isActive !== undefined) user.isActive = isActive;
  await user.save();

  res.status(200).json(new ApiResponse(200, user.toPublicProfile(), 'User updated'));
});

const getStats = asyncHandler(async (req, res) => {
  const sevenDaysAgo = new Date(Date.now() - 7 * 86_400_000);

  const [totalUsers, proUsers, freeUsers, newSignups, newContactMessages] = await Promise.all([
    User.countDocuments({}),
    User.countDocuments({ subscriptionPlan: 'pro' }),
    User.countDocuments({ subscriptionPlan: 'free' }),
    User.countDocuments({ createdAt: { $gte: sevenDaysAgo } }),
    ContactMessage.countDocuments({ status: 'new' }),
  ]);

  res.status(200).json(
    new ApiResponse(200, {
      totalUsers,
      proUsers,
      freeUsers,
      newSignupsLast7Days: newSignups,
      newContactMessages,
    }),
  );
});

// GET /api/admin/leads — every tagged call (note or lead status) across all
// businesses, newest first, with the business it belongs to.
const listLeads = asyncHandler(async (req, res) => {
  const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
  const limit = Math.min(parseInt(req.query.limit, 10) || 20, 100);
  const { status } = req.query;

  const validStatuses = ['new', 'interested', 'followup', 'won', 'lost'];
  const filter = validStatuses.includes(status) ? { status } : {};

  const [notes, total] = await Promise.all([
    CallNote.find(filter)
      .sort({ updatedAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .populate('user', 'businessName email'),
    CallNote.countDocuments(filter),
  ]);

  res.status(200).json(
    new ApiResponse(200, {
      leads: notes.map((n) => ({
        ...n.toPublicProfile(),
        business: n.user ? { id: n.user._id.toString(), businessName: n.user.businessName, email: n.user.email } : null,
      })),
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    }),
  );
});

module.exports = { listUsers, getUser, updateUser, getStats, listLeads };
