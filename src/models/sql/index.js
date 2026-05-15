'use strict';

const { Sequelize, DataTypes } = require('sequelize');

let sequelize;

function createSequelize() {
  if (process.env.DATABASE_URL) {
    return new Sequelize(process.env.DATABASE_URL, {
      dialect: process.env.DB_DIALECT || 'mysql',
      logging: process.env.NODE_ENV === 'development' ? console.log : false,
    });
  }

  return new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    dialect: process.env.DB_DIALECT || 'mysql',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
  });
}

if (!sequelize) {
  sequelize = createSequelize();
}

const db = {
  Sequelize,
  sequelize,
  User: require('./User')(sequelize, DataTypes),
  Event: require('./Event')(sequelize, DataTypes),
  Vendor: require('./Vendor')(sequelize, DataTypes),
  Rundown: require('./Rundown')(sequelize, DataTypes),
  Tugas: require('./Tugas')(sequelize, DataTypes),
  LaporanKetua: require('./LaporanKetua')(sequelize, DataTypes),
};

Object.keys(db).forEach((modelName) => {
  if (db[modelName] && typeof db[modelName].associate === 'function') {
    db[modelName].associate(db);
  }
});

module.exports = db;