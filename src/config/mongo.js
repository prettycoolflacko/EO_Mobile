const mongoose = require('mongoose');

async function connectMongo() {
  if (!process.env.MONGO_URI) {
    return null;
  }

  await mongoose.connect(process.env.MONGO_URI);
  return mongoose.connection;
}

module.exports = { connectMongo };