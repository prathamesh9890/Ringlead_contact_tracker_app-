const jwt = require('jsonwebtoken');
const { randomUUID } = require('node:crypto');
const env = require('../config/env');

function signAccessToken(user) {
  return jwt.sign({ sub: user._id.toString(), role: user.role }, env.jwtAccessSecret, {
    expiresIn: env.jwtAccessExpiresIn,
  });
}

function signRefreshToken(user) {
  // jti makes every refresh token unique even if issued for the same user within
  // the same second (iat has only second precision) — without it, two logins
  // close together would produce byte-identical tokens and collide on the
  // RefreshToken collection's unique index.
  return jwt.sign({ sub: user._id.toString(), jti: randomUUID() }, env.jwtRefreshSecret, {
    expiresIn: env.jwtRefreshExpiresIn,
  });
}

function verifyAccessToken(token) {
  return jwt.verify(token, env.jwtAccessSecret);
}

function verifyRefreshToken(token) {
  return jwt.verify(token, env.jwtRefreshSecret);
}

const DURATION_UNIT_MS = { s: 1000, m: 60_000, h: 3_600_000, d: 86_400_000 };

/** Converts a duration string like "30d" / "15m" into a future Date, for storing expiresAt in the DB. */
function durationFromNow(duration) {
  const match = /^(\d+)([smhd])$/.exec(duration);
  if (!match) throw new Error(`Unsupported duration format: ${duration}`);
  const [, amount, unit] = match;
  return new Date(Date.now() + Number(amount) * DURATION_UNIT_MS[unit]);
}

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  durationFromNow,
};
