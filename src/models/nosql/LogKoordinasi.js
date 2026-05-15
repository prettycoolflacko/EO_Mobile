const mongoose = require('mongoose');

const schema = new mongoose.Schema(
  {
    event_id: { type: Number, required: true },
    user_id: { type: Number, required: true },
    aksi: { type: String, required: true },
    entity: { type: String, enum: ['tugas', 'vendor', 'rundown', 'event'], required: true },
    entity_id: { type: Number, required: true },
    detail: { type: Object, default: {} },
    ip_address: { type: String },
  },
  { timestamps: { createdAt: 'timestamp', updatedAt: false } }
);

module.exports = mongoose.model('LogKoordinasi', schema, 'log_koordinasi');