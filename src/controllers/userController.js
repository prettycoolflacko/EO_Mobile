const db = require('../models/sql');
const { successResponse, errorResponse } = require('../utils/response');

function sanitizeUser(user) {
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

async function listUsers(req, res, next) {
  try {
    const users = await db.User.findAll({
      attributes: { exclude: ['password_hash'] },
      order: [['created_at', 'DESC']],
    });

    return successResponse(res, {
      message: 'Daftar user berhasil diambil',
      data: { users: users.map(sanitizeUser) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function getUserById(req, res, next) {
  try {
    const userId = req.params.id;
    const user = await db.User.findByPk(userId, {
      attributes: { exclude: ['password_hash'] },
    });

    if (!user) {
      return errorResponse(res, { message: 'User tidak ditemukan', statusCode: 404 });
    }

    return successResponse(res, {
      message: 'Detail user berhasil diambil',
      data: { user: sanitizeUser(user) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function updateUser(req, res, next) {
  try {
    const userId = req.params.id;
    const user = await db.User.findByPk(userId);

    if (!user) {
      return errorResponse(res, { message: 'User tidak ditemukan', statusCode: 404 });
    }

    const payload = {
      name: req.body.name ?? user.name,
      phone: req.body.phone ?? user.phone,
      avatar_url: req.body.avatar_url ?? user.avatar_url,
      divisi: req.body.divisi ?? user.divisi,
      is_active: req.body.is_active !== undefined ? req.body.is_active : user.is_active,
    };

    await user.update(payload);

    const refreshed = await db.User.findByPk(userId);
    return successResponse(res, {
      message: 'User berhasil diperbarui',
      data: { user: sanitizeUser(refreshed) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function deleteUser(req, res, next) {
  try {
    const userId = req.params.id;
    const deletedRows = await db.User.destroy({ where: { id: userId } });

    if (!deletedRows) {
      return errorResponse(res, { message: 'User tidak ditemukan', statusCode: 404 });
    }

    return res.status(204).send();
  } catch (error) {
    next(error);
  }
}

module.exports = { listUsers, getUserById, updateUser, deleteUser };