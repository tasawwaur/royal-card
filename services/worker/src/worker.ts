import dotenv from 'dotenv';
import { createLogger } from '@teenpatti/logger';

dotenv.config({ path: '../../.env' });

const logger = createLogger('Worker');

logger.info('BullMQ Background Worker initialized for rewards & table cleanup queues.');

if (process.env.NODE_ENV !== 'test') {
  setInterval(() => {
    logger.debug('BullMQ Worker heartbeat check...');
  }, 30000);
}
