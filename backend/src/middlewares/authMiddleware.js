import jwt from "jsonwebtoken";
import env from "../utils/consts.js";
import { ApiError } from "../utils/ApiError.js";
import User from "../models/user.js";
import BlacklistedToken from "../models/blacklistedToken.js";
import { parseTimeString } from "../utils/helpers.js";

export const verifyJWT = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'] || req.headers['x-auth-token'];

        if (!authHeader) {
            return next(new ApiError(401, 'Access token is required'));
        }

        const token = authHeader.startsWith('Bearer ')
            ? authHeader.substring(7)
            : authHeader;

        const isBlacklisted = await isTokenBlacklisted(token);
        if (isBlacklisted) {
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

export const addToBlacklist = async (token, userId) => {
    const expiresInMs = parseTimeString(env.jwt.refreshExpiresIn);
    const expiresAt = new Date(Date.now() + expiresInMs);

    await BlacklistedToken.create({
        token,
        userId,
        expiresAt
    });
};

export const isTokenBlacklisted = async (token) => {
    const blacklistedToken = await BlacklistedToken.findOne({ token });
    return !!blacklistedToken;
}; 