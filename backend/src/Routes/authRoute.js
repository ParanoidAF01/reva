import express from "express";
import {
    register,
    login,
    sendOtp,
    verifyOtp,
    forgotPassword,
    logout,
    refreshAccessToken
} from "../controllers/authController.js";
import { authenticateToken } from "../middlewares/authMiddleware.js";
import { asyncHandler } from "../middlewares/errorHandler.js";

const authRoute = express.Router();

authRoute.post('/register', asyncHandler(register));
authRoute.post('/login', asyncHandler(login));
authRoute.post('/send-otp', asyncHandler(sendOtp));
authRoute.post('/verify-otp', asyncHandler(verifyOtp));
authRoute.post('/forgot-password', asyncHandler(forgotPassword));
authRoute.post('/refresh-token', asyncHandler(refreshAccessToken));

authRoute.post('/logout', authenticateToken, asyncHandler(logout));

export default authRoute;