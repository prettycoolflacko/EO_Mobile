const db = require('../models/sql');
const { Op } = require('sequelize');
const { successResponse, errorResponse } = require('../utils/response');
const { getPaginationParams, buildPaginationMeta, getSortParams } = require('../utils/pagination');
const { findVisibleEventById } = require('../utils/eventAccess');

function buildLaporanPayload(laporan) {
  return {
    id: laporan.id,
    event_id: laporan.event_id,
    ketua_id: laporan.ketua_id,
    judul: laporan.judul,
    konten: laporan.konten,
    file_url: laporan.file_url,
    tanggal: laporan.tanggal,
    ketua: laporan.ketua ? { id: laporan.ketua.id, name: laporan.ketua.name, email: laporan.ketua.email } : null,
    created_at: laporan.created_at,
  };
}

async function createLaporan(req, res, next) {
  try {
    const eventId = req.params.id;
    const { judul, konten, file_url = null, tanggal = new Date() } = req.body;
    const userId = req.auth?.id;

    if (!judul || !konten) {
      return errorResponse(res, { message: 'Judul dan konten wajib diisi', statusCode: 400 });
    }

    const event = await findVisibleEventById(eventId, req);
    if (!event) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    const laporan = await db.LaporanKetua.create({
      event_id: eventId,
      ketua_id: userId,
      judul,
      konten,
      file_url,
      tanggal,
    });

    const refreshed = await db.LaporanKetua.findByPk(laporan.id, {
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email'] }],
    });

    return successResponse(res, {
      message: 'Laporan berhasil dibuat',
      data: { laporan: buildLaporanPayload(refreshed) },
      statusCode: 201,
    });
  } catch (error) {
    next(error);
  }
}

async function listLaporanByEvent(req, res, next) {
  try {
    const eventId = req.params.id;
    const event = await findVisibleEventById(eventId, req);

    if (!event) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    const { page, perPage, offset, limit } = getPaginationParams(req.query);
    const { sortBy, order } = getSortParams(req.query, {
      allowedSortBy: ['created_at', 'tanggal', 'judul'],
      defaultSortBy: 'created_at',
      defaultOrder: 'DESC',
    });
    const where = { event_id: eventId };

    if (req.query.ketua_id) {
      where.ketua_id = req.query.ketua_id;
    }

    if (req.query.tanggal_from || req.query.tanggal_to) {
      where.tanggal = {};
      if (req.query.tanggal_from) {
        where.tanggal[Op.gte] = req.query.tanggal_from;
      }
      if (req.query.tanggal_to) {
        where.tanggal[Op.lte] = req.query.tanggal_to;
      }
    }

    if (req.query.q) {
      where[Op.or] = [
        { judul: { [Op.like]: `%${req.query.q}%` } },
        { konten: { [Op.like]: `%${req.query.q}%` } },
      ];
    }

    const { rows, count } = await db.LaporanKetua.findAndCountAll({
      where,
      order: [[sortBy, order]],
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email'] }],
      offset,
      limit,
      distinct: true,
    });

    return successResponse(res, {
      message: 'Daftar laporan berhasil diambil',
      data: { laporan: rows.map(buildLaporanPayload) },
      meta: buildPaginationMeta({ page, perPage, total: count }),
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { createLaporan, listLaporanByEvent };