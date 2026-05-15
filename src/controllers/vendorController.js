const db = require('../models/sql');
const { successResponse, errorResponse } = require('../utils/response');

function buildVendorPayload(vendor) {
  return {
    id: vendor.id,
    nama_vendor: vendor.nama_vendor,
    kategori: vendor.kategori,
    kontak_person: vendor.kontak_person,
    telepon: vendor.telepon,
    email: vendor.email,
    alamat: vendor.alamat,
    kontrak_url: vendor.kontrak_url,
    event_id: vendor.event_id,
    status: vendor.status,
    catatan: vendor.catatan,
    created_at: vendor.created_at,
  };
}

async function createVendor(req, res, next) {
  try {
    const eventId = req.params.id;
    const { nama_vendor, kategori = null, kontak_person = null, telepon = null, email = null, alamat = null, kontrak_url = null, status = 'aktif', catatan = null } = req.body;

    if (!nama_vendor) {
      return errorResponse(res, { message: 'Nama vendor wajib diisi', statusCode: 400 });
    }

    const event = await db.Event.findByPk(eventId);
    if (!event) {
      return errorResponse(res, { message: 'Event tidak ditemukan', statusCode: 404 });
    }

    const vendor = await db.Vendor.create({
      nama_vendor,
      kategori,
      kontak_person,
      telepon,
      email,
      alamat,
      kontrak_url,
      event_id: eventId,
      status,
      catatan,
    });

    return successResponse(res, {
      message: 'Vendor berhasil ditambahkan',
      data: { vendor: buildVendorPayload(vendor) },
      statusCode: 201,
    });
  } catch (error) {
    next(error);
  }
}

async function listVendorsByEvent(req, res, next) {
  try {
    const eventId = req.params.id;
    const vendors = await db.Vendor.findAll({
      where: { event_id: eventId },
      order: [['created_at', 'DESC']],
    });

    return successResponse(res, {
      message: 'Daftar vendor berhasil diambil',
      data: { vendors: vendors.map(buildVendorPayload) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function getVendorById(req, res, next) {
  try {
    const vendorId = req.params.id;
    const vendor = await db.Vendor.findByPk(vendorId);

    if (!vendor) {
      return errorResponse(res, { message: 'Vendor tidak ditemukan', statusCode: 404 });
    }

    return successResponse(res, {
      message: 'Detail vendor berhasil diambil',
      data: { vendor: buildVendorPayload(vendor) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function updateVendor(req, res, next) {
  try {
    const vendorId = req.params.id;
    const vendor = await db.Vendor.findByPk(vendorId);

    if (!vendor) {
      return errorResponse(res, { message: 'Vendor tidak ditemukan', statusCode: 404 });
    }

    const payload = {
      nama_vendor: req.body.nama_vendor ?? vendor.nama_vendor,
      kategori: req.body.kategori ?? vendor.kategori,
      kontak_person: req.body.kontak_person ?? vendor.kontak_person,
      telepon: req.body.telepon ?? vendor.telepon,
      email: req.body.email ?? vendor.email,
      alamat: req.body.alamat ?? vendor.alamat,
      kontrak_url: req.body.kontrak_url ?? vendor.kontrak_url,
      status: req.body.status ?? vendor.status,
      catatan: req.body.catatan ?? vendor.catatan,
    };

    await vendor.update(payload);

    const refreshed = await db.Vendor.findByPk(vendorId);
    return successResponse(res, {
      message: 'Vendor berhasil diperbarui',
      data: { vendor: buildVendorPayload(refreshed) },
      statusCode: 200,
    });
  } catch (error) {
    next(error);
  }
}

async function deleteVendor(req, res, next) {
  try {
    const vendorId = req.params.id;
    const deletedRows = await db.Vendor.destroy({ where: { id: vendorId } });

    if (!deletedRows) {
      return errorResponse(res, { message: 'Vendor tidak ditemukan', statusCode: 404 });
    }

    return res.status(204).send();
  } catch (error) {
    next(error);
  }
}

module.exports = { createVendor, listVendorsByEvent, getVendorById, updateVendor, deleteVendor };