const { successResponse, errorResponse } = require('../utils/response');

async function uploadFile(req, res, next) {
  try {
    if (!req.file) {
      return errorResponse(res, { message: 'File wajib diupload', statusCode: 400 });
    }

    const fileUrl = `/uploads/${req.file.filename}`;

    return successResponse(res, {
      message: 'File berhasil diupload',
      data: {
        file: {
          filename: req.file.filename,
          originalname: req.file.originalname,
          mimetype: req.file.mimetype,
          size: req.file.size,
          url: fileUrl,
        },
      },
      statusCode: 201,
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { uploadFile };