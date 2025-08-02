import axios from "axios";
import jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import env from "../utils/consts.js";
import { AppError, asyncHandler } from "../middlewares/errorHandler.js";
import User from "../models/user.js";
import Profile from "../models/profile.js";
import { addToBlacklist, isTokenBlacklisted } from "../middlewares/authMiddleware.js";

// Registration
export const register = asyncHandler(async (req, res) => {
    const {
        email,
        mobileNumber,
        mpin,
        firstName,
        lastName,
        dateOfBirth,
        gender,
        designation,
        experience,
        location
    } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({
        $or: [{ email }, { mobileNumber }]
    });

    if (existingUser) {
        throw new AppError('User with this email or mobile number already exists', 400);
    }

    // Create user
    const user = await User.create({
        email,
        mobileNumber,
        mpin
    });

    // Create profile
    const profile = await Profile.create({
        user: user._id,
        firstName,
        lastName,
        dateOfBirth,
        gender,
        designation,
        experience,
        location
    });

    // Generate tokens
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

    // Update user with refresh token
    user.refreshToken = refreshToken;
    user.refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await user.save();

    res.status(201).json({
        success: true,
        message: "User registered successfully",
        data: {
            user: {
                id: user._id,
                email: user.email,
                mobileNumber: user.mobileNumber,
                isEmailVerified: user.isEmailVerified,
                isPhoneVerified: user.isPhoneVerified
            },
            profile: {
                id: profile._id,
                fullName: profile.fullName,
                designation: profile.designation,
                location: profile.location
            },
            tokens: {
                accessToken,
                refreshToken
            }
        }
    });
});

// Login
export const login = asyncHandler(async (req, res) => {
    const { mobileNumber, mpin } = req.body;

    // Find user
    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new AppError('Invalid mobile number or MPIN', 401);
    }

    // Check if account is locked
    if (user.isLocked) {
        throw new AppError('Account is temporarily locked due to multiple failed attempts', 423);
    }

    // Verify MPIN
    const isMpinValid = await user.compareMpin(mpin);
    if (!isMpinValid) {
        await user.incLoginAttempts();
        throw new AppError('Invalid mobile number or MPIN', 401);
    }

    // Reset login attempts on successful login
    await user.resetLoginAttempts();

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    // Generate tokens
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

    // Update user with new refresh token
    user.refreshToken = refreshToken;
    user.refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await user.save();

    // Get profile
    const profile = await Profile.findOne({ user: user._id });

    res.status(200).json({
        success: true,
        message: "Login successful",
        data: {
            user: {
                id: user._id,
                email: user.email,
                mobileNumber: user.mobileNumber,
                isEmailVerified: user.isEmailVerified,
                isPhoneVerified: user.isPhoneVerified
            },
            profile: profile ? {
                id: profile._id,
                fullName: profile.fullName,
                designation: profile.designation,
                location: profile.location
            } : null,
            tokens: {
                accessToken,
                refreshToken
            }
        }
    });
});

// Send OTP
export const sendOtp = asyncHandler(async (req, res) => {
    const { mobileNumber } = req.body;

    // Validate mobile number
    if (!mobileNumber || !/^[0-9]{10}$/.test(mobileNumber)) {
        throw new AppError('Please provide a valid 10-digit mobile number', 400);
    }

    // Check if user exists
    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new AppError('Mobile number not registered', 404);
    }

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Update user with OTP
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
        throw new AppError('Failed to send OTP. Please try again.', 500);
    }
});

// Verify OTP
export const verifyOtp = asyncHandler(async (req, res) => {
    const { mobileNumber, otp } = req.body;

    // Validate inputs
    if (!mobileNumber || !otp) {
        throw new AppError('Mobile number and OTP are required', 400);
    }

    // Find user
    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new AppError('Mobile number not registered', 404);
    }

    // Check if OTP exists and is not expired
    if (!user.otp || !user.otpExpiresAt || user.otpExpiresAt < new Date()) {
        throw new AppError('OTP has expired or is invalid', 400);
    }

    // Verify OTP
    if (user.otp !== otp) {
        throw new AppError('Invalid OTP', 400);
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
        throw new AppError('MPIN must be 4-6 digits', 400);
    }

    // Find user
    const user = await User.findOne({ mobileNumber });
    if (!user) {
        throw new AppError('Mobile number not registered', 404);
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
        throw new AppError('Refresh token is required', 400);
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
        throw new AppError('Refresh token is required', 400);
    }

    // Check if token is blacklisted
    if (isTokenBlacklisted(refreshToken)) {
        throw new AppError('Token has been invalidated', 401);
    }

    try {
        // Verify refresh token
        const decoded = jwt.verify(refreshToken, env.jwt.refreshSecret);

        // Find user
        const user = await User.findById(decoded.id);
        if (!user || user.refreshToken !== refreshToken) {
            throw new AppError('Invalid refresh token', 401);
        }

        // Check if refresh token is expired
        if (user.refreshTokenExpiresAt < new Date()) {
            throw new AppError('Refresh token expired', 401);
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
        user.refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
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
            throw new AppError('Invalid refresh token', 401);
        }
        if (error.name === 'TokenExpiredError') {
            throw new AppError('Refresh token expired', 401);
        }
        throw error;
    }
});
