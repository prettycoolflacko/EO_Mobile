require('dotenv').config();

const app = require('./app');
const { connectSql } = require('./config/sql');
const { connectMongo } = require('./config/mongo');

const PORT = process.env.PORT || 8080;

async function bootstrap() {
  await connectSql();
  await connectMongo();

  app.listen(PORT, () => {
    console.log(`EventSync backend running on port ${PORT}`);
  });
}

bootstrap().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});