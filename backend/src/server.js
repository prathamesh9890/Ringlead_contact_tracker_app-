const env = require('./config/env');
const { connectDb, disconnectDb } = require('./config/db');
const app = require('./app');

async function start() {
  await connectDb();

  const server = app.listen(env.port, () => {
    console.log(`[server] Ringlead API listening on port ${env.port} (${env.nodeEnv})`);
  });

  const shutdown = async (signal) => {
    console.log(`[server] received ${signal}, shutting down...`);
    server.close(async () => {
      await disconnectDb();
      process.exit(0);
    });
  };

  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

start().catch((err) => {
  console.error('[server] failed to start:', err);
  process.exit(1);
});
