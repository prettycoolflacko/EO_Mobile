const db = require('../models/sql');

function isPrivilegedRole(role) {
  return role === 'admin' || role === 'ketua';
}

function buildEventVisibilityInclude(currentUserRole, currentUserId) {
  if (isPrivilegedRole(currentUserRole)) {
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

async function findVisibleEventById(eventId, req) {
  const currentUserRole = req.auth?.role;
  const currentUserId = req.auth?.id;

  if (isPrivilegedRole(currentUserRole)) {
    return db.Event.findByPk(eventId);
  }

  if (!currentUserId) {
    return null;
  }

  return db.Event.findOne({
    where: { id: eventId },
    include: buildEventVisibilityInclude(currentUserRole, currentUserId),
    distinct: true,
  });
}

module.exports = {
  buildEventVisibilityInclude,
  findVisibleEventById,
  isPrivilegedRole,
};