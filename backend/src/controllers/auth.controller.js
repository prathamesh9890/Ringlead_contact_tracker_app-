const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const ApiResponse = require('../utils/ApiResponse');
const User = require('../models/user.model');
const RefreshToken = require('../models/refreshToken.model');
const { hashPassword, comparePassword } = require('../utils/password');
const { signAccessToken, signRefreshToken, verifyRefreshToken, durationFromNow } = require('../utils/jwt');
const env = require('../config/env');

async function issueTokenPair(user) {
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  await RefreshToken.create({
    token: refreshToken,
    userId: user._id,
    expiresAt: durationFromNow(env.jwtRefreshExpiresIn),
  });
  return { accessToken, refreshToken };
}

const register = asyncHandler(async (req, res) => {
  const { email, password, businessName, phone } = req.body;

  const existing = await User.findOne({ email: email.toLowerCase() });
  if (existing) {
    throw new ApiError(409, 'An account with this email already existed');
  }

  const passwordHash = await hashPassword(password);
  const user = await User.create({ email, passwordHash, businessName, phone });

  const tokens = await issueTokenPair(user);
  res.status(201).json(new ApiResponse(201, { user: user.toPublicProfile(), ...tokens }, 'Account created'));
});

const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email: email.toLowerCase() }).select('+passwordHash');
  if (!user) {
    throw new ApiError(401, 'Invalid email or password');
  }
  if (!user.isActive) {
    throw new ApiError(403, 'This account has been suspended');
  }

  const passwordMatches = await comparePassword(password, user.passwordHash);
  if (!passwordMatches) {
    throw new ApiError(401, 'Invalid email or password');
  }

  const tokens = await issueTokenPair(user);
  res.status(200).json(new ApiResponse(200, { user: user.toPublicProfile(), ...tokens }, 'Logged in'));
});

const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    throw new ApiError(400, 'refreshToken is required');
  }

  let payload;
  try {
    payload = verifyRefreshToken(refreshToken);
  } catch {
    throw new ApiError(401, 'Invalid or expired refresh token');
  }

  const stored = await RefreshToken.findOne({ token: refreshToken });
  if (!stored) {
    throw new ApiError(401, 'Refresh token has been revoked');
  }

  const user = await User.findById(payload.sub);
  if (!user || !user.isActive) {
    throw new ApiError(401, 'Account is no longer available');
  }

  // Rotate: delete the used refresh token and issue a fresh pair.
  await RefreshToken.deleteOne({ _id: stored._id });
  const tokens = await issueTokenPair(user);
  res.status(200).json(new ApiResponse(200, tokens, 'Token refreshed'));
});

const logout = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (refreshToken) {
    await RefreshToken.deleteOne({ token: refreshToken });
  }
  res.status(200).json(new ApiResponse(200, null, 'Logged out'));
});

module.exports = { register, login, refresh, logout };
