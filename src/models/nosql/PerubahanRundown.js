const mongoose = require('mongoose');

const schema = new mongoose.Schema(
  {
    rundown_id: { type: Number, required: true },
    event_id: { type: Number, required: true },
    field_berubah: { type: String, required: true },
    nilai_lama: { type: String },
    nilai_baru: { type: String },
    diubah_oleh: { type: Number, required: true },
    alasan: { type: String },
  },
  { timestamps: { createdAt: 'timestamp', updatedAt: false } }
);

module.exports = mongoose.model('PerubahanRundown', schema, 'perubahan_rundown');