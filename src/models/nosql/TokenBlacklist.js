const mongoose = require('mongoose');

const schema = new mongoose.Schema(
  {
    token: { type: String, required: true, unique: true },
    user_id: { type: Number, required: true },
    expires_at: { type: Date, required: true },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } }
);

module.exports = mongoose.model('TokenBlacklist', schema, 'token_blacklist');