const mongoose = require('mongoose');
const env = require('./env');

async function connectDb() {
  mongoose.set('strictQuery', true);

  try {
    await mongoose.connect(env.mongodbUri);
    console.log('[db] connected to MongoDB');
  } catch (err) {
    console.error('[db] failed to connect to MongoDB:', err.message);
    process.exit(1);
  }

  mongoose.connection.on('error', (err) => {
    console.error('[db] connection error:', err.message);
  });
}

async function disconnectDb() {
  await mongoose.connection.close();
}

module.exports = { connectDb, disconnectDb };
