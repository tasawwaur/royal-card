import pino, { Logger as PinoInstance, LoggerOptions } from 'pino';

export type Logger = PinoInstance;

export function createLogger(serviceName: string, level: string = process.env.LOG_LEVEL || 'info'): Logger {
  const options: LoggerOptions = {
    name: serviceName,
    level,
    transport:
      process.env.NODE_ENV !== 'production'
        ? {
            target: 'pino-pretty',
            options: {
              colorize: true,
              translateTime: 'SYS:standard',
              ignore: 'pid,hostname',
            },
          }
        : undefined,
  };

  return pino(options);
}
