function successResponse(res, { message = 'Berhasil', data = null, meta = null, statusCode = 200 }) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    ...(meta ? { meta } : {}),
  });
}

function errorResponse(res, { message = 'Terjadi kesalahan', errors = [], statusCode = 400 }) {
  return res.status(statusCode).json({
    success: false,
    message,
    ...(errors.length ? { errors } : {}),
  });
}

module.exports = { successResponse, errorResponse };