const db = require('../models/sql');
const { successResponse, errorResponse } = require('../utils/response');

function buildTugasPayload(tugas) {
  return {
    id: tugas.id,
    event_id: tugas.event_id,
    rundown_id: tugas.rundown_id,
    judul: tugas.judul,
    deskripsi: tugas.deskripsi,
    assignee_id: tugas.assignee_id,
    assignee: tugas.assignee ? {
      id: tugas.assignee.id,
      name: tugas.assignee.name,
      email: tugas.assignee.email,
      divisi: tugas.assignee.divisi,
    } : null,
    divisi: tugas.divisi,
    prioritas: tugas.prioritas,
    status: tugas.status,
    deadline: tugas.deadline,
    lampiran_url: tugas.lampiran_url,
    catatan: tugas.catatan,
    created_at: tugas.created_at,
    updated_at: tugas.updated_at,
  };
}

async function createTugas(req, res, next) {
  try {
    const eventId = req.params.id;
    const { judul, deskripsi = null, assignee_id, divisi = null, prioritas = 'sedang', status = 'belum', deadline = null, lampiran_url = null, catatan = null, rundown_id = null } = req.body;

    if (!judul || !assignee_id) {
      return errorResponse(res, { message: 'Judul dan assignee wajib diisi', statusCode: 400 });
    }

    const event = await db.Event.findByPk(eventId);
    if (!event) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    const tugas = await db.Tugas.create({
      event_id: eventId,
      rundown_id,
      judul,
      deskripsi,
      assignee_id,
      divisi,
      prioritas,
      status,
      deadline,
      lampiran_url,
      catatan,
    });

    const refreshed = await db.Tugas.findByPk(tugas.id, {
      include: [{ model: db.User, as: 'assignee', attributes: ['id', 'name', 'email', 'divisi'] }],
    });

    return successResponse(res, {
      message: 'Tugas berhasil dibuat',
      data: { tugas: buildTugasPayload(refreshed) },
      statusCode: 201,
    });
  } catch (error) {
    next(error);
  }
}

async function listTugasByEvent(req, res, next) {
  try {
    const eventId = req.params.id;
    const tugas = await db.Tugas.findAll({
      where: { event_id: eventId },
      order: [['created_at', 'DESC']],
      include: [{ model: db.User, as: 'assignee', attributes: ['id', 'name', 'email', 'divisi'] }],
    });

    return successResponse(res, {
      message: 'Daftar tugas berhasil diambil',
      data: { tugas: tugas.map(buildTugasPayload) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function getTugasById(req, res, next) {
  try {
    const tugasId = req.params.id;
    const tugas = await db.Tugas.findByPk(tugasId, {
      include: [{ model: db.User, as: 'assignee', attributes: ['id', 'name', 'email', 'divisi'] }],
    });

    if (!tugas) {
      return errorResponse(res, { message: 'Tugas tidak ditemukan', statusCode: 404 });
    }

    return successResponse(res, {
      message: 'Detail tugas berhasil diambil',
      data: { tugas: buildTugasPayload(tugas) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function updateTugas(req, res, next) {
  try {
    const tugasId = req.params.id;
    const tugas = await db.Tugas.findByPk(tugasId);

    if (!tugas) {
      return errorResponse(res, { message: 'Tugas tidak ditemukan', statusCode: 404 });
    }

    const payload = {
      judul: req.body.judul ?? tugas.judul,
      deskripsi: req.body.deskripsi ?? tugas.deskripsi,
      assignee_id: req.body.assignee_id ?? tugas.assignee_id,
      divisi: req.body.divisi ?? tugas.divisi,
      prioritas: req.body.prioritas ?? tugas.prioritas,
      status: req.body.status ?? tugas.status,
      deadline: req.body.deadline ?? tugas.deadline,
      lampiran_url: req.body.lampiran_url ?? tugas.lampiran_url,
      catatan: req.body.catatan ?? tugas.catatan,
    };

    await tugas.update(payload);

    const refreshed = await db.Tugas.findByPk(tugasId, {
      include: [{ model: db.User, as: 'assignee', attributes: ['id', 'name', 'email', 'divisi'] }],
    });

    return successResponse(res, {
      message: 'Tugas berhasil diperbarui',
      data: { tugas: buildTugasPayload(refreshed) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function updateTugasStatus(req, res, next) {
  try {
    const tugasId = req.params.id;
    const { status, catatan = null } = req.body;

    if (!status) {
      return errorResponse(res, { message: 'Status wajib diisi', statusCode: 400 });
    }

    const tugas = await db.Tugas.findByPk(tugasId);
    if (!tugas) {
      return errorResponse(res, { message: 'Tugas tidak ditemukan', statusCode: 404 });
    }

    const payload = { status };
    if (catatan !== null) {
      payload.catatan = catatan;
    }

    await tugas.update(payload);

    const refreshed = await db.Tugas.findByPk(tugasId, {
      include: [{ model: db.User, as: 'assignee', attributes: ['id', 'name', 'email', 'divisi'] }],
    });

    return successResponse(res, {
      message: 'Status tugas berhasil diperbarui',
      data: { tugas: buildTugasPayload(refreshed) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function deleteTugas(req, res, next) {
  try {
    const tugasId = req.params.id;
    const deletedRows = await db.Tugas.destroy({ where: { id: tugasId } });

    if (!deletedRows) {
      return errorResponse(res, { message: 'Tugas tidak ditemukan', statusCode: 404 });
    }

    return res.status(204).send();
  } catch (error) {
    next(error);
  }
}

module.exports = { createTugas, listTugasByEvent, getTugasById, updateTugas, updateTugasStatus, deleteTugas };