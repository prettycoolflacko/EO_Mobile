const { errorResponse } = require('../utils/response');

function roleMiddleware(roles = []) {
  return (req, res, next) => {
    const userRole = req.auth?.role;

    if (!userRole) {
      return errorResponse(res, { message: 'Token tidak valid', statusCode: 401 });
    }

    if (roles.length && !roles.includes(userRole)) {
      return errorResponse(res, { message: 'Tidak punya izin', statusCode: 403 });
    }

    return next();
  };
}

module.exports = roleMiddleware;