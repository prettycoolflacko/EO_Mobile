const mongoose = require('mongoose');

const schema = new mongoose.Schema(
  {
    event_id: { type: Number, required: true },
    divisi: { type: String, required: true },
    pesan: { type: String, required: true },
    pengirim_id: { type: Number, required: true },
    pengirim_nama: { type: String, required: true },
    tipe: { type: String, enum: ['text', 'gambar', 'file'], default: 'text' },
    file_url: { type: String, default: null },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } }
);

module.exports = mongoose.model('ChatDivisi', schema, 'chat_divisi');