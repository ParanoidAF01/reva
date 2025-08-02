import jwt from "jsonwebtoken";
import env from "../utils/consts.js";
import { AppError } from "./errorHandler.js";
import User from "../models/user.js";

// In-memory blacklist for logged out tokens (use Redis in production)
const blacklistedTokens = new Set();

export const authenticateToken = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'] || req.headers['x-auth-token'];

        if (!authHeader) {
            return next(new AppError('Access token is required', 401));
        }

        const token = authHeader.startsWith('Bearer ')
            ? authHeader.substring(7)
            : authHeader;

        if (blacklistedTokens.has(token)) {
            return next(new AppError('Token has been invalidated', 401));
        }

        const decoded = jwt.verify(token, env.jwt.secret);

        const user = await User.findById(decoded.id).select('-mpin -refreshToken');
        if (!user) {
            return next(new AppError('User no longer exists', 401));
        }

        if (!user.isActive) {
            return next(new AppError('User account is deactivated', 401));
        }

        req.user = user;
        next();
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return next(new AppError('Invalid token', 401));
        }
        if (error.name === 'TokenExpiredError') {
            return next(new AppError('Token expired', 401));
        }
        return next(new AppError('Authentication failed', 401));
    }
};

export const requireRole = (roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return next(new AppError('Authentication required', 401));
        }

        if (!roles.includes(req.user.role)) {
            return next(new AppError('Insufficient permissions', 403));
        }

        next();
    };
};

export const requireAdmin = (req, res, next) => {
    if (!req.user) {
        return next(new AppError('Authentication required', 401));
    }

    if (!req.user.isAdmin) {
        return next(new AppError('Admin access required', 403));
    }

    next();
};

export const addToBlacklist = (token) => {
    blacklistedTokens.add(token);
    setTimeout(() => {
        blacklistedTokens.delete(token);
    }, 24 * 60 * 60 * 1000);
};

export const isTokenBlacklisted = (token) => {
    return blacklistedTokens.has(token);
}; 