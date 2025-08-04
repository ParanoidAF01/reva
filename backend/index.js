import express from "express";
import cors from "cors";
import morgan from "morgan";
import env from "./src/utils/consts.js";
import connectDB from "./src/utils/db.js";
import indexRouting from "./src/route/indexRoute.js";
import { errorHandler, notFound } from "./src/middlewares/errorHandler.js";

const app = express();

connectDB();

app.use(cors({
    origin: env.security.corsOrigin,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-auth-token']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const morganFormat = ':method :url :status';
app.use(morgan(morganFormat));

app.get('/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Server is healthy',
        timestamp: new Date().toISOString(),
        environment: env.config.nodeEnv
    });
});

app.use('/api/v1', indexRouting);

app.use(notFound);

app.use(errorHandler);

process.on('SIGTERM', () => {
    console.log('SIGTERM received. Shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received. Shutting down gracefully...');
    process.exit(0);
});

process.on('unhandledRejection', (err) => {
    console.error('Unhandled Promise Rejection:', err.message);
    process.exit(1);
});

process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err.message);
    process.exit(1);
});

const port = env.config.port;

app.listen(port, () => {
    console.log(`Server is running on port ${port} in ${env.config.nodeEnv} mode`);
    console.log(`Health check: http://localhost:${port}/health`);
});