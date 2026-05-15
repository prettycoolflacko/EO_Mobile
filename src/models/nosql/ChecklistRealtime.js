const mongoose = require('mongoose');

const schema = new mongoose.Schema(
  {
    tugas_id: { type: Number, required: true },
    event_id: { type: Number, required: true },
    user_id: { type: Number, required: true },
    status: { type: String, enum: ['belum', 'proses', 'selesai', 'terkendala'], default: 'belum' },
    catatan: { type: String },
    location: {
      lat: Number,
      lng: Number,
    },
  },
  { timestamps: { createdAt: false, updatedAt: 'updated_at' } }
);

module.exports = mongoose.model('ChecklistRealtime', schema, 'checklist_realtime');