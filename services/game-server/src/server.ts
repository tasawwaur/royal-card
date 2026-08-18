import http from 'node:http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import { createLogger } from '@teenpatti/logger';

dotenv.config({ path: '../../.env' });

const logger = createLogger('GameServer');
const server = http.createServer();
const io = new Server(server, {
  cors: {
    origin: '*',
  },
});

io.on('connection', (socket) => {
  logger.info(`Player connected: ${socket.id}`);

  socket.on('join_table', (data) => {
    logger.info(`Socket ${socket.id} requested to join table`, data);
  });

  socket.on('disconnect', () => {
    logger.info(`Player disconnected: ${socket.id}`);
  });
});

const PORT = Number(process.env.GAME_SERVER_PORT) || 5000;

if (process.env.NODE_ENV !== 'test') {
  server.listen(PORT, () => {
    logger.info(`Real-time Socket.IO Game Server running on port ${PORT}`);
  });
}

export default server;
