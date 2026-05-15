const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../models/sql');
const { TokenBlacklist } = require('../models/nosql');
const { successResponse, errorResponse } = require('../utils/response');

function sanitizeUser(user) {
  if (!user) {
    return null;
  }

  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    divisi: user.divisi,
    phone: user.phone,
    avatar_url: user.avatar_url,
    is_active: user.is_active,
    created_at: user.created_at,
    updated_at: user.updated_at,
  };
}

function createTokenPayload(user) {
  return {
    sub: String(user.id),
    id: user.id,
    email: user.email,
    role: user.role,
  };
}

async function register(req, res, next) {
  try {
    const { name, email, password, role = 'staf', divisi = null, phone = null, avatar_url = null } = req.body;

    if (!name || !email || !password) {
      return errorResponse(res, {
        message: 'Nama, email, dan password wajib diisi',
        statusCode: 400,
      });
    }

    if (!['staf'].includes(role)) {
      return errorResponse(res, {
        message: 'Registrasi publik hanya boleh membuat role staf',
        statusCode: 403,
      });
    }

    const existingUser = await db.User.findOne({ where: { email } });
    if (existingUser) {
      return errorResponse(res, {
        message: 'Email sudah digunakan',
        statusCode: 400,
        errors: [{ field: 'email', message: 'Email sudah digunakan' }],
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const createdUser = await db.User.create({
      name,
      email,
      password_hash: passwordHash,
      role,
      divisi,
      phone,
      avatar_url,
      is_active: true,
    });

    return successResponse(res, {
      message: 'User berhasil didaftarkan',
      data: { user: sanitizeUser(createdUser) },
      statusCode: 201,
    });
  } catch (error) {
    next(error);
  }
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return errorResponse(res, {
        message: 'Email dan password wajib diisi',
        statusCode: 400,
      });
    }

    const user = await db.User.findOne({ where: { email } });
    if (!user) {
      return errorResponse(res, { message: 'Email atau password salah', statusCode: 401 });
    }

    if (!user.is_active) {
      return errorResponse(res, { message: 'Akun tidak aktif', statusCode: 403 });
    }

    const passwordMatch = await bcrypt.compare(password, user.password_hash);
    if (!passwordMatch) {
      return errorResponse(res, { message: 'Email atau password salah', statusCode: 401 });
    }

    const secret = process.env.JWT_SECRET;
    if (!secret) {
      return errorResponse(res, { message: 'JWT_SECRET belum dikonfigurasi', statusCode: 500 });
    }

    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';
    const token = jwt.sign(createTokenPayload(user), secret, { expiresIn });

    return successResponse(res, {
      message: 'Login berhasil',
      data: {
        token,
        token_type: 'Bearer',
        expires_in: expiresIn,
        user: sanitizeUser(user),
      },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function me(req, res, next) {
  try {
    const userId = req.auth?.id;
    if (!userId) {
      return errorResponse(res, { message: 'Token tidak valid', statusCode: 401 });
    }

    const user = await db.User.findByPk(userId);
    if (!user) {
      return errorResponse(res, { message: 'User tidak ditemukan', statusCode: 404 });
    }

    return successResponse(res, {
      message: 'Profil user berhasil diambil',
      data: { user: sanitizeUser(user) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function logout(req, res, next) {
  try {
    const userId = req.auth?.id;
    const token = req.token;

    if (!userId || !token) {
      return errorResponse(res, { message: 'Token tidak valid', statusCode: 401 });
    }

    const decoded = jwt.decode(token);
    const expiresAt = decoded?.exp ? new Date(decoded.exp * 1000) : new Date(Date.now() + 24 * 60 * 60 * 1000);

    await TokenBlacklist.findOneAndUpdate(
      { token },
      { token, user_id: userId, expires_at: expiresAt },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    return successResponse(res, {
      message: 'Logout berhasil',
      data: { token_revoked: true },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { register, login, me, logout };