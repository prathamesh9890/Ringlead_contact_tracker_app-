const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');

const getMe = asyncHandler(async (req, res) => {
  res.status(200).json(new ApiResponse(200, req.user.toPublicProfile()));
});

const updateMe = asyncHandler(async (req, res) => {
  const { businessName, phone } = req.body;
  if (businessName !== undefined) req.user.businessName = businessName;
  if (phone !== undefined) req.user.phone = phone;
  await req.user.save();
  res.status(200).json(new ApiResponse(200, req.user.toPublicProfile(), 'Profile updated'));
});

module.exports = { getMe, updateMe };
