const mongoose = require('mongoose');

const schema = new mongoose.Schema(
  {
    user_id: { type: Number, required: true },
    event_id: { type: Number, required: true },
    judul: { type: String, required: true },
    pesan: { type: String, required: true },
    tipe: { type: String, enum: ['tugas', 'rundown', 'vendor', 'sistem'], required: true },
    is_read: { type: Boolean, default: false },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } }
);

module.exports = mongoose.model('Notifikasi', schema, 'notifikasi');