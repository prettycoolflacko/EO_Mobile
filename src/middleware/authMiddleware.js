const jwt = require('jsonwebtoken');
const { TokenBlacklist } = require('../models/nosql');
const { errorResponse } = require('../utils/response');

async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, { message: 'Token tidak ada', statusCode: 401 });
    }

    const token = authHeader.slice(7);
    const blacklistEntry = await TokenBlacklist.findOne({ token });

    if (blacklistEntry) {
      return errorResponse(res, { message: 'Token sudah tidak berlaku', statusCode: 401 });
    }

    const secret = process.env.JWT_SECRET;
    if (!secret) {
      return errorResponse(res, { message: 'JWT_SECRET belum dikonfigurasi', statusCode: 500 });
    }

    const decoded = jwt.verify(token, secret);
    req.auth = decoded;
    req.token = token;

    return next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return errorResponse(res, { message: 'Token expired', statusCode: 401 });
    }

    return errorResponse(res, { message: 'Token tidak valid', statusCode: 401 });
  }
}

module.exports = authMiddleware;