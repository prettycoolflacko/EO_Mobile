function ownerMiddleware(req, res, next) {
  res.status(501).json({ success: false, message: 'ownerMiddleware belum diimplementasikan' });
}

module.exports = ownerMiddleware;