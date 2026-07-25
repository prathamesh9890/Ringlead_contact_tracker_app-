const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');

const getMine = asyncHandler(async (req, res) => {
  res.status(200).json(
    new ApiResponse(200, {
      plan: req.user.subscriptionPlan,
      isActive: req.user.isActive,
    }),
  );
});

// TODO: this is a placeholder until Razorpay is integrated. Once that's wired up,
// plan changes should only happen after a verified payment webhook, not this
// direct client-triggered update.
const updateMine = asyncHandler(async (req, res) => {
  const { plan } = req.body;
  req.user.subscriptionPlan = plan;
  await req.user.save();
  res.status(200).json(new ApiResponse(200, { plan: req.user.subscriptionPlan }, 'Subscription updated'));
});

module.exports = { getMine, updateMine };
