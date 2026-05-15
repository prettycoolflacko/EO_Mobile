const db = require('../models/sql');
const { successResponse, errorResponse } = require('../utils/response');

function buildRundownPayload(rundown) {
  return {
    id: rundown.id,
    event_id: rundown.event_id,
    urutan: rundown.urutan,
    waktu_mulai: rundown.waktu_mulai,
    waktu_selesai: rundown.waktu_selesai,
    judul_sesi: rundown.judul_sesi,
    deskripsi: rundown.deskripsi,
    pic_id: rundown.pic_id,
    pic: rundown.pic ? { id: rundown.pic.id, name: rundown.pic.name } : null,
    vendor_id: rundown.vendor_id,
    vendor: rundown.vendor ? { id: rundown.vendor.id, nama_vendor: rundown.vendor.nama_vendor } : null,
    status: rundown.status,
    created_at: rundown.created_at,
    updated_at: rundown.updated_at,
  };
}

async function createRundown(req, res, next) {
  try {
    const eventId = req.params.id;
    const { urutan, waktu_mulai, waktu_selesai = null, judul_sesi, deskripsi = null, pic_id = null, vendor_id = null, status = 'belum' } = req.body;

    if (!urutan || !waktu_mulai || !judul_sesi) {
      return errorResponse(res, { message: 'Urutan, waktu mulai, dan judul sesi wajib diisi', statusCode: 400 });
    }

    const event = await db.Event.findByPk(eventId);
    if (!event) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    const rundown = await db.Rundown.create({
      event_id: eventId,
      urutan,
      waktu_mulai,
      waktu_selesai,
      judul_sesi,
      deskripsi,
      pic_id,
      vendor_id,
      status,
    });

    const refreshed = await db.Rundown.findByPk(rundown.id, {
      include: [
        { model: db.User, as: 'pic', attributes: ['id', 'name'] },
        { model: db.Vendor, as: 'vendor', attributes: ['id', 'nama_vendor'] },
      ],
    });

    return successResponse(res, {
      message: 'Rundown berhasil ditambahkan',
      data: { rundown: buildRundownPayload(refreshed) },
      statusCode: 201,
    });
  } catch (error) {
    next(error);
  }
}

async function listRundownsByEvent(req, res, next) {
  try {
    const eventId = req.params.id;
    const rundowns = await db.Rundown.findAll({
      where: { event_id: eventId },
      order: [['urutan', 'ASC']],
      include: [
        { model: db.User, as: 'pic', attributes: ['id', 'name'] },
        { model: db.Vendor, as: 'vendor', attributes: ['id', 'nama_vendor'] },
      ],
    });

    return successResponse(res, {
      message: 'Daftar rundown berhasil diambil',
      data: { rundowns: rundowns.map(buildRundownPayload) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function updateRundown(req, res, next) {
  try {
    const rundownId = req.params.id;
    const rundown = await db.Rundown.findByPk(rundownId);

    if (!rundown) {
      return errorResponse(res, { message: 'Rundown tidak ditemukan', statusCode: 404 });
    }

    const payload = {
      urutan: req.body.urutan ?? rundown.urutan,
      waktu_mulai: req.body.waktu_mulai ?? rundown.waktu_mulai,
      waktu_selesai: req.body.waktu_selesai ?? rundown.waktu_selesai,
      judul_sesi: req.body.judul_sesi ?? rundown.judul_sesi,
      deskripsi: req.body.deskripsi ?? rundown.deskripsi,
      pic_id: req.body.pic_id ?? rundown.pic_id,
      vendor_id: req.body.vendor_id ?? rundown.vendor_id,
      status: req.body.status ?? rundown.status,
    };

    await rundown.update(payload);

    const refreshed = await db.Rundown.findByPk(rundownId, {
      include: [
        { model: db.User, as: 'pic', attributes: ['id', 'name'] },
        { model: db.Vendor, as: 'vendor', attributes: ['id', 'nama_vendor'] },
      ],
    });

    return successResponse(res, {
      message: 'Rundown berhasil diperbarui',
      data: { rundown: buildRundownPayload(refreshed) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function deleteRundown(req, res, next) {
  try {
    const rundownId = req.params.id;
    const deletedRows = await db.Rundown.destroy({ where: { id: rundownId } });

    if (!deletedRows) {
      return errorResponse(res, { message: 'Rundown tidak ditemukan', statusCode: 404 });
    }

    return res.status(204).send();
  } catch (error) {
    next(error);
  }
}

module.exports = { createRundown, listRundownsByEvent, updateRundown, deleteRundown };