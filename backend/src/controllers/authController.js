import axios from "axios";
import jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import env from "../utils/consts.js";
import { asyncHandler } from "../middlewares/errorHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import User from "../models/user.js";
import Profile from "../models/profile.js";
import { addToBlacklist, isTokenBlacklisted } from "../middlewares/authMiddleware.js";
import { generateOTP, parseTimeString } from "../utils/helpers.js";

export const register = asyncHandler(async (req, res) => {
    const {
        fullName,
        email,
        mobileNumber,
        mpin,
    } = req.body;

    const existingUser = await User.findOne({
        $or: [{ email }, { mobileNumber }]
    });

    if (existingUser) {
        throw new ApiError(400, 'User with this email or mobile number already exists');
    }

    const user = await User.create({
        email,
        fullName,
        mobileNumber,
        mpin
    });

    const profile = await Profile.create({
        user: user._id,
    });

    await user.save();
    await profile.save();

    res.status(201).json({
        success: true,
        message: "User registered successfully",
        data: {
            user: {
                id: user._id,
                email: user.email,
                mobileNumber: user.mobileNumber,
                fullName: user.fullName,
                mpin: user.mpin
            },
            profile: {
                id: profile._id,
            },
        }
    });
});

export const login = asyncHandler(async (req, res) => {
    const { mobileNumber, mpin } = req.body;

    const user = await User.findOne({ mobileNumber });

    if (!user) {
        throw new ApiError(401, 'Invalid mobile number or MPIN');
    }

    const isMpinValid = await user.compareMpin(mpin);

    if (!isMpinValid) {
        throw new ApiError(401, 'Invalid mobile number or MPIN');
    }

    const accessToken = jwt.sign(
        { id: user._id },
        env.jwt.secret,
        { expiresIn: env.jwt.expiresIn }
    );

    const refreshToken = jwt.sign(
        { id: user._id },
        env.jwt.refreshSecret,
        { expiresIn: env.jwt.refreshExpiresIn }
    );

    user.refreshToken = refreshToken;
    const refreshExpiresInMs = parseTimeString(env.jwt.refreshExpiresIn);
    user.refreshTokenExpiresAt = new Date(Date.now() + refreshExpiresInMs);
    await user.save();

    const profile = await Profile.findOne({ user: user._id });

    res.status(200).json({
        success: true,
        message: "Login successful",
        data: {
            user: {
                id: user._id,
                email: user.email,
                mobileNumber: user.mobileNumber,
                fullName: user.fullName,
                mpin: user.mpin
            },
            profile: {
                id: profile._id,
            },
            tokens: {
                accessToken,
                refreshToken
            }
        }
    });
});

export const verifyMpin = asyncHandler(async (req, res) => {
    const { mpin } = req.body;
    if (!mpin) {
        throw new ApiError(400, 'MPIN is required');
    }

    const userId = req.user._id;
    if (!userId) {
        throw new ApiError(401, 'User not found');
    }

    const user = await User.findById(userId);
    if (!user) {
        throw new ApiError(404, 'User not found');
    }

    const isMpinValid = await user.compareMpin(mpin);
    if (!isMpinValid) {
        throw new ApiError(401, 'Invalid MPIN');
    }

    res.status(200).json({
        success: true,
        message: "MPIN verified successfully",
        data: {
            isMpinValid: true
        }
    });
});

export const sendOtp = asyncHandler(async (req, res) => {
    const { mobileNumber } = req.body;

    if (!mobileNumber || !/^[0-9]{10}$/.test(mobileNumber)) {
        throw new ApiError(400, 'Please provide a valid 10-digit mobile number');
    }

    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new ApiError(404, 'Mobile number not registered');
    }

    const otp = generateOTP();
    const otpExpiresAt = new Date(Date.now() + parseTimeString(env.otp.expiresIn));

    user.otp = otp;
    user.otpExpiresAt = otpExpiresAt;
    await user.save();

    // Send OTP via SMS (using your existing service)
    try {
        await axios.post(env.otp.verifyUrl, {
            "Text": `Use ${otp} as your User Verification code. Expires in 5 minutes. This code is Confidential. Never Share it with anyone for your safety. LEXORA`,
            "Number": "91" + mobileNumber,
            "SenderId": "LEXORA",
            "DRNotifyUrl": "https://www.domainname.com/notifyurl",
            "DRNotifyHttpMethod": "POST",
            "Tool": "API"
        }, {
            headers: {
                'Content-Type': 'application/json',
            },
            auth: {
                userName: env.otp.authKey,
                password: env.otp.authToken,
            },
        });

        res.status(200).json({
            success: true,
            message: "OTP sent successfully",
            data: {
                mobileNumber: mobileNumber.replace(/(\d{3})(\d{3})(\d{4})/, '$1***$3'),
                expiresIn: "5 minutes"
            }
        });
    } catch (error) {
        console.error('OTP sending failed:', error);
        throw new ApiError(500, 'Failed to send OTP. Please try again.');
    }
});

// Verify OTP
export const verifyOtp = asyncHandler(async (req, res) => {
    const { mobileNumber, otp } = req.body;

    // Validate inputs
    if (!mobileNumber || !otp) {
        throw new ApiError(400, 'Mobile number and OTP are required');
    }

    // Find user
    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new ApiError(404, 'Mobile number not registered');
    }

    // Check if OTP exists and is not expired
    if (!user.otp || !user.otpExpiresAt || user.otpExpiresAt < new Date()) {
        throw new ApiError(400, 'OTP has expired or is invalid');
    }

    // Verify OTP
    if (user.otp !== otp) {
        throw new ApiError(400, 'Invalid OTP');
    }

    // Update user verification status
    user.otpVerified = true;
    user.isPhoneVerified = true;
    user.otp = null;
    user.otpExpiresAt = null;
    await user.save();

    res.status(200).json({
        success: true,
        message: "OTP verified successfully",
        data: {
            isPhoneVerified: true
        }
    });
});

// Forgot Password
export const forgotPassword = asyncHandler(async (req, res) => {
    const { mobileNumber, newMpin } = req.body;

    // Validate new MPIN
    if (!newMpin || newMpin.length < 4 || newMpin.length > 6) {
        throw new ApiError(400, 'MPIN must be 4-6 digits');
    }

    // Find user
    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new ApiError(404, 'Mobile number not registered');
    }

    // Update MPIN
    user.mpin = newMpin;
    await user.save();

    res.status(200).json({
        success: true,
        message: "Password updated successfully"
    });
});

// Logout
export const logout = asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        throw new ApiError(400, 'Refresh token is required');
    }

    // Add token to blacklist
    addToBlacklist(refreshToken);

    // Clear refresh token from user
    if (req.user) {
        req.user.refreshToken = null;
        req.user.refreshTokenExpiresAt = null;
        await req.user.save();
    }

    res.status(200).json({
        success: true,
        message: "Logged out successfully"
    });
});

// Refresh Access Token
export const refreshAccessToken = asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        throw new ApiError(400, 'Refresh token is required');
    }

    // Check if token is blacklisted
    if (isTokenBlacklisted(refreshToken)) {
        throw new ApiError(401, 'Token has been invalidated');
    }

    try {
        // Verify refresh token
        const decoded = jwt.verify(refreshToken, env.jwt.refreshSecret);

        // Find user
        const user = await User.findById(decoded.id);
        if (!user || user.refreshToken !== refreshToken) {
            throw new ApiError(401, 'Invalid refresh token');
        }

        // Check if refresh token is expired
        if (user.refreshTokenExpiresAt < new Date()) {
            throw new ApiError(401, 'Refresh token expired');
        }

        // Generate new tokens
        const newAccessToken = jwt.sign(
            { id: user._id },
            env.jwt.secret,
            { expiresIn: env.jwt.expiresIn }
        );

        const newRefreshToken = jwt.sign(
            { id: user._id },
            env.jwt.refreshSecret,
            { expiresIn: env.jwt.refreshExpiresIn }
        );

        // Update user with new refresh token
        user.refreshToken = newRefreshToken;
        const refreshExpiresInMs = parseTimeString(env.jwt.refreshExpiresIn);
        user.refreshTokenExpiresAt = new Date(Date.now() + refreshExpiresInMs);
        await user.save();

        // Add old token to blacklist
        addToBlacklist(refreshToken);

        res.status(200).json({
            success: true,
            message: "Token refreshed successfully",
            data: {
                accessToken: newAccessToken,
                refreshToken: newRefreshToken
            }
        });
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            throw new ApiError(401, 'Invalid refresh token');
        }
        if (error.name === 'TokenExpiredError') {
            throw new ApiError(401, 'Refresh token expired');
        }
        throw error;
    }
});
