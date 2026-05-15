const db = require('../models/sql');
const { successResponse, errorResponse } = require('../utils/response');

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

    const event = await db.Event.findByPk(eventId);
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
    const laporan = await db.LaporanKetua.findAll({
      where: { event_id: eventId },
      order: [['created_at', 'DESC']],
      include: [{ model: db.User, as: 'ketua', attributes: ['id', 'name', 'email'] }],
    });

    return successResponse(res, {
      message: 'Daftar laporan berhasil diambil',
      data: { laporan: laporan.map(buildLaporanPayload) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { createLaporan, listLaporanByEvent };