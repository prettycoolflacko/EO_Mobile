const db = require('../models/sql');
const { Op } = require('sequelize');
const { successResponse, errorResponse } = require('../utils/response');
const { getPaginationParams, buildPaginationMeta, getSortParams } = require('../utils/pagination');

function buildEventVisibilityInclude(currentUserRole, currentUserId) {
  if (currentUserRole === 'admin' || currentUserRole === 'ketua') {
    return [];
  }

  if (!currentUserId) {
    return [];
  }

  return [{
    model: db.Tugas,
    as: 'tugas',
    attributes: [],
    required: true,
    where: { assignee_id: currentUserId },
  }];
}

function buildEventPayload(event) {
  return {
    id: event.id,
    nama_event: event.nama_event,
    deskripsi: event.deskripsi,
    lokasi: event.lokasi,
    tanggal_mulai: event.tanggal_mulai,
    tanggal_selesai: event.tanggal_selesai,
    status: event.status,
    ketua_id: event.ketua_id,
    ketua: event.ketua ? {
      id: event.ketua.id,
      name: event.ketua.name,
      email: event.ketua.email,
      role: event.ketua.role,
    } : null,
    created_at: event.created_at,
    updated_at: event.updated_at,
  };
}

async function createEvent(req, res, next) {
  try {
    const { nama_event, deskripsi = null, lokasi = null, tanggal_mulai, tanggal_selesai, status = 'draft', ketua_id } = req.body;
    const currentUserId = req.auth?.id;
    const currentUserRole = req.auth?.role;

    if (!nama_event || !tanggal_mulai || !tanggal_selesai) {
      return errorResponse(res, {
        message: 'Nama event, tanggal mulai, dan tanggal selesai wajib diisi',
        statusCode: 400,
      });
    }

    const assignedKetuaId = currentUserRole === 'admin' ? (ketua_id || currentUserId) : currentUserId;

    const createdEvent = await db.Event.create({
      nama_event,
      deskripsi,
      lokasi,
      tanggal_mulai,
      tanggal_selesai,
      status,
      ketua_id: assignedKetuaId,
    });

    const event = await db.Event.findByPk(createdEvent.id, {
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email', 'role'] }],
    });

    return successResponse(res, {
      message: 'Event berhasil dibuat',
      data: { event: buildEventPayload(event) },
      statusCode: 201,
    });
  } catch (error) {
    next(error);
  }
}

async function listEvents(req, res, next) {
  try {
    const { page, perPage, offset, limit } = getPaginationParams(req.query);
    const { sortBy, order } = getSortParams(req.query, {
      allowedSortBy: ['created_at', 'tanggal_mulai', 'tanggal_selesai', 'nama_event'],
      defaultSortBy: 'created_at',
      defaultOrder: 'DESC',
    });
    const where = {};
    const currentUserRole = req.auth?.role;
    const currentUserId = req.auth?.id;
    const visibilityInclude = buildEventVisibilityInclude(currentUserRole, currentUserId);

    if (req.query.status) {
      where.status = req.query.status;
    }

    if (req.query.ketua_id) {
      where.ketua_id = req.query.ketua_id;
    }

    if (req.query.tanggal_mulai_from || req.query.tanggal_mulai_to) {
      where.tanggal_mulai = {};
      if (req.query.tanggal_mulai_from) {
        where.tanggal_mulai[Op.gte] = req.query.tanggal_mulai_from;
      }
      if (req.query.tanggal_mulai_to) {
        where.tanggal_mulai[Op.lte] = req.query.tanggal_mulai_to;
      }
    }

    if (req.query.q) {
      where[Op.or] = [
        { nama_event: { [Op.like]: `%${req.query.q}%` } },
        { lokasi: { [Op.like]: `%${req.query.q}%` } },
      ];
    }

    const { rows, count } = await db.Event.findAndCountAll({
      where,
      order: [[sortBy, order]],
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email', 'role'] }],
      ...(visibilityInclude.length ? { include: [...visibilityInclude, { model: db.User, as: 'ketua', attributes: ['id', 'name', 'email', 'role'] }] } : {}),
      offset,
      limit,
      distinct: true,
    });

    return successResponse(res, {
      message: 'Daftar event berhasil diambil',
      data: { events: rows.map(buildEventPayload) },
      meta: buildPaginationMeta({ page, perPage, total: count }),
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function getEventById(req, res, next) {
  try {
    const eventId = req.params.id;
    const currentUserRole = req.auth?.role;
    const currentUserId = req.auth?.id;
    const visibilityInclude = buildEventVisibilityInclude(currentUserRole, currentUserId);
    const event = await db.Event.findOne({
      where: { id: eventId },
      include: [
        { model: db.User, as: 'ketua', attributes: ['id', 'name', 'email', 'role'] },
        ...visibilityInclude,
      ],
      distinct: true,
    });

    if (!event) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    const [vendorCount, rundownCount, taskCount] = await Promise.all([
      db.Vendor.count({ where: { event_id: eventId } }),
      db.Rundown.count({ where: { event_id: eventId } }),
      db.Tugas.count({ where: { event_id: eventId } }),
    ]);

    return successResponse(res, {
      message: 'Detail event berhasil diambil',
      data: {
        event: buildEventPayload(event),
        statistics: {
          vendors: vendorCount,
          rundowns: rundownCount,
          tasks: taskCount,
        },
      },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function updateEvent(req, res, next) {
  try {
    const eventId = req.params.id;
    const event = await db.Event.findByPk(eventId);

    if (!event) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    const payload = {
      nama_event: req.body.nama_event ?? event.nama_event,
      deskripsi: req.body.deskripsi ?? event.deskripsi,
      lokasi: req.body.lokasi ?? event.lokasi,
      tanggal_mulai: req.body.tanggal_mulai ?? event.tanggal_mulai,
      tanggal_selesai: req.body.tanggal_selesai ?? event.tanggal_selesai,
      status: req.body.status ?? event.status,
    };

    await event.update(payload);

    const refreshedEvent = await db.Event.findByPk(eventId, {
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email', 'role'] }],
    });

    return successResponse(res, {
      message: 'Event berhasil diperbarui',
      data: { event: buildEventPayload(refreshedEvent) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function deleteEvent(req, res, next) {
  try {
    const eventId = req.params.id;
    const deletedRows = await db.Event.destroy({ where: { id: eventId } });

    if (!deletedRows) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    return res.status(204).send();
  } catch (error) {
    next(error);
  }
}

module.exports = { createEvent, listEvents, getEventById, updateEvent, deleteEvent };