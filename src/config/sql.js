const { Sequelize } = require('sequelize');

let sequelizeInstance;

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

async function connectSql() {
  if (!sequelizeInstance) {
    sequelizeInstance = createSequelize();
  }

  await sequelizeInstance.authenticate();
  return sequelizeInstance;
}

function getSqlInstance() {
  if (!sequelizeInstance) {
    sequelizeInstance = createSequelize();
  }

  return sequelizeInstance;
}

module.exports = { connectSql, getSqlInstance };