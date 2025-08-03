import jwt from "jsonwebtoken";
import env from "../utils/consts.js";
import { ApiError } from "../utils/ApiError.js";
import User from "../models/user.js";

const blacklistedTokens = new Set();

export const verifyJWT = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'] || req.headers['x-auth-token'];

        if (!authHeader) {
            return next(new ApiError(401, 'Access token is required'));
        }

        const token = authHeader.startsWith('Bearer ')
            ? authHeader.substring(7)
            : authHeader;

        if (blacklistedTokens.has(token)) {
            return next(new ApiError(401, 'Token has been invalidated'));
        }

        const decoded = jwt.verify(token, env.jwt.secret);

        const user = await User.findById(decoded.id).select('-mpin -refreshToken');

        if (!user) {
            return next(new ApiError(401, 'User no longer exists'));
        }

        req.user = user;

        next();

    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return next(new ApiError(401, 'Invalid token'));
        }
        if (error.name === 'TokenExpiredError') {
            return next(new ApiError(401, 'Token expired'));
        }
        return next(new ApiError(401, 'Authentication failed'));
    }
};

export const requireAdmin = (req, res, next) => {
    if (!req.user) {
        return next(new ApiError(401, 'Authentication required'));
    }

    if (!req.user.isAdmin) {
        return next(new ApiError(403, 'Admin access required'));
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