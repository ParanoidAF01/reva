import env from "./consts.js";

class Logger {
    constructor() {
        this.level = 'info';
        this.levels = {
            error: 0,
            warn: 1,
            info: 2,
            debug: 3
        };
    }

    shouldLog(level) {
        return this.levels[level] <= this.levels[this.level];
    }

    formatMessage(level, message, meta = {}) {
        const timestamp = new Date().toISOString();
        const logEntry = {
            timestamp,
            level: level.toUpperCase(),
            message,
            ...meta
        };

        if (env.config.nodeEnv === 'development') {
            return JSON.stringify(logEntry, null, 2);
        }

        return JSON.stringify(logEntry);
    }

    error(message, meta = {}) {
        if (this.shouldLog('error')) {
            console.error(this.formatMessage('error', message, meta));
        }
    }

    warn(message, meta = {}) {
        if (this.shouldLog('warn')) {
            console.warn(this.formatMessage('warn', message, meta));
        }
    }

    info(message, meta = {}) {
        if (this.shouldLog('info')) {
            console.info(this.formatMessage('info', message, meta));
        }
    }

    debug(message, meta = {}) {
        if (this.shouldLog('debug')) {
            console.debug(this.formatMessage('debug', message, meta));
        }
    }

    logRequest(req, res, next) {
        const start = Date.now();

        res.on('finish', () => {
            const duration = Date.now() - start;
            const logData = {
                method: req.method,
                url: req.originalUrl,
                status: res.statusCode,
                duration: `${duration}ms`,
                userAgent: req.get('User-Agent'),
                ip: req.ip,
                userId: req.user?.id || 'anonymous'
            };

            if (res.statusCode >= 400) {
                this.error('HTTP Request Error', logData);
            } else {
                this.info('HTTP Request', logData);
            }
        });

        next();
    }

    logDatabase(operation, collection, duration, error = null) {
        const logData = {
            operation,
            collection,
            duration: `${duration}ms`
        };

        if (error) {
            this.error('Database Error', { ...logData, error: error.message });
        } else {
            this.debug('Database Operation', logData);
        }
    }

    logAuth(action, userId, success, details = {}) {
        const logData = {
            action,
            userId,
            success,
            ...details
        };

        if (success) {
            this.info('Authentication Success', logData);
        } else {
            this.warn('Authentication Failure', logData);
        }
    }
}

const logger = new Logger();

export { logger }; 