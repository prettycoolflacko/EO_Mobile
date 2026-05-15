const db = require('../models/sql');
const { successResponse, errorResponse } = require('../utils/response');

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
    const events = await db.Event.findAll({
      order: [['created_at', 'DESC']],
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email', 'role'] }],
    });

    return successResponse(res, {
      message: 'Daftar event berhasil diambil',
      data: { events: events.map(buildEventPayload) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function getEventById(req, res, next) {
  try {
    const eventId = req.params.id;
    const event = await db.Event.findByPk(eventId, {
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email', 'role'] }],
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