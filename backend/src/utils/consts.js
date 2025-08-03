import dotenv from "dotenv";

dotenv.config();

const env = {
    config: {
        port: process.env.PORT || 3000,
        nodeEnv: process.env.NODE_ENV || "production",
        corsOrigin: process.env.CORS_ORIGIN || "*",
    },

    mongodb: {
        url: process.env.MONGODB_URL || "mongodb://localhost:27017/reva",
    },

    jwt: {
        secret: process.env.JWT_SECRET || "your-secret-key",
        expiresIn: process.env.JWT_EXPIRES_IN || "1h",
        refreshSecret: process.env.JWT_REFRESH_SECRET || "your-refresh-secret-key",
        refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || "7d",
    },

    otp: {
        authKey: process.env.OTP_AUTH_KEY || null,
        authToken: process.env.OTP_AUTH_TOKEN || null,
        verifyUrl: process.env.OTP_VERIFY_URL || null,
        expiresIn: process.env.OTP_EXPIRES_IN || "5m",
    },

    security: {
        bcryptRounds: process.env.BCRYPT_ROUNDS || 12,
    },

    razorpay: {
        keyId: process.env.RAZORPAY_KEY_ID,
        keySecret: process.env.RAZORPAY_KEY_SECRET,
    },

}

export default env;
