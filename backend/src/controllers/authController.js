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
import { sendWelcomeNotification } from "../utils/notificationService.js";

export const register = asyncHandler(async (req, res) => {
    const {
        fullName,
        email,
        mobileNumber,
        mpin,
    } = req.body;
    if (!fullName || !email || !mobileNumber || !mpin) {
        throw new ApiError(400, 'All fields are required');
    }
    if (!/^[0-9]{6}$/.test(mpin)) {
        throw new ApiError(400, 'MPIN must be 6 digits long');
    }

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

    user.profile = profile._id;

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
    await profile.save();

    try {
        await sendWelcomeNotification(user._id, user.fullName);
    } catch (error) {
        console.error('Failed to send welcome notification:', error);
    }

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
            tokens: {
                accessToken,
                refreshToken
            }
        }
    });
});

export const login = asyncHandler(async (req, res) => {
    const { mobileNumber, mpin } = req.body;

    const user = await User.findOne({ mobileNumber });

    if (!user) {
        throw new ApiError(401, 'Invalid mobile number or MPIN');
    }

    if (!user.otpVerified) {
        throw new ApiError(401, 'OTP verification is required');
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

    if (!env.otp.authKey || !env.otp.authToken || !env.otp.verifyUrl) {
        console.log(`OTP for ${mobileNumber}: ${otp}`);
        return res.status(200).json({
            success: true,
            message: "OTP sent successfully (SMS service not configured - check console for OTP)",
            data: {
                mobileNumber: mobileNumber.replace(/(\d{3})(\d{3})(\d{4})/, '$1***$3'),
                expiresIn: "5 minutes",
                otp: otp
            }
        });
    }

    try {
        const response = await axios.post(env.otp.verifyUrl, {
            "Text": `Use ${otp} as your User Verification code. This code is Confidential. Never Share it with anyone for your safety. LEXORA`,
            "Number": "91" + mobileNumber,
            "SenderId": "LEXORA",
            "DRNotifyUrl": "https://www.domainname.com/notifyurl",
            "DRNotifyHttpMethod": "POST",
            "Tool": "API"
        }, {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Basic ${Buffer.from(`${env.otp.authKey}:${env.otp.authToken}`).toString('base64')}`
            }
        });

        if (response.data.Success) {
            res.status(200).json({
                success: true,
                message: "OTP sent successfully",
                data: {
                    mobileNumber: mobileNumber.replace(/(\d{3})(\d{3})(\d{4})/, '$1***$3'),
                    expiresIn: "5 minutes"
                }
            });
        } else {
            console.error('SMS service error:', response.data);
            throw new Error(response.data.Message || 'SMS service error');
        }
    } catch (error) {
        console.error('OTP sending failed:', error.response?.data || error.message);

        if (error.response?.status === 401) {
            console.log(`OTP for ${mobileNumber}: ${otp} (SMS auth failed - using fallback)`);
            return res.status(200).json({
                success: true,
                message: "OTP sent successfully (SMS authentication failed - check console for OTP)",
                data: {
                    mobileNumber: mobileNumber.replace(/(\d{3})(\d{3})(\d{4})/, '$1***$3'),
                    expiresIn: "5 minutes",
                    otp: otp
                }
            });
        }

        throw new ApiError(500, 'Failed to send OTP. Please try again.');
    }
});

export const verifyOtp = asyncHandler(async (req, res) => {
    const { mobileNumber, otp } = req.body;

    if (!mobileNumber || !otp) {
        throw new ApiError(400, 'Mobile number and OTP are required');
    }

    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new ApiError(404, 'Mobile number not registered');
    }

    if (!user.otp || !user.otpExpiresAt || user.otpExpiresAt < new Date()) {
        throw new ApiError(400, 'OTP has expired or is invalid');
    }

    if (user.otp !== otp) {
        throw new ApiError(400, 'Invalid OTP');
    }

    user.otpVerified = true;
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

export const forgotPassword = asyncHandler(async (req, res) => {
    const { mobileNumber, newMpin } = req.body;

    if (!newMpin || newMpin.length < 4 || newMpin.length > 6) {
        throw new ApiError(400, 'MPIN must be 4-6 digits');
    }

    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new ApiError(404, 'Mobile number not registered');
    }

    user.mpin = newMpin;
    await user.save();

    res.status(200).json({
        success: true,
        message: "Password updated successfully"
    });
});

export const logout = asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        throw new ApiError(400, 'Refresh token is required');
    }

    await addToBlacklist(refreshToken, req.user._id);

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

export const refreshAccessToken = asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        throw new ApiError(400, 'Refresh token is required');
    }

    const isBlacklisted = await isTokenBlacklisted(refreshToken);
    if (isBlacklisted) {
        throw new ApiError(401, 'Token has been invalidated');
    }

    try {
        const decoded = jwt.verify(refreshToken, env.jwt.refreshSecret);

        const user = await User.findById(decoded.id);
        if (!user || user.refreshToken !== refreshToken) {
            throw new ApiError(401, 'Invalid refresh token');
        }

        if (user.refreshTokenExpiresAt < new Date()) {
            throw new ApiError(401, 'Refresh token expired');
        }

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

        user.refreshToken = newRefreshToken;
        const refreshExpiresInMs = parseTimeString(env.jwt.refreshExpiresIn);
        user.refreshTokenExpiresAt = new Date(Date.now() + refreshExpiresInMs);
        await user.save();

        await addToBlacklist(refreshToken, user._id);

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
