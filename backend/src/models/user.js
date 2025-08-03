import mongoose from "mongoose";
import bcrypt from "bcrypt";
import env from "../utils/consts.js";

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
        match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
    },
    mobileNumber: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        match: [/^[0-9]{10}$/, 'Please enter a valid 10-digit mobile number']
    },
    mpin: {
        type: String,
        required: true,
        length: 6
    },
    fullName: {
        type: String,
        required: true
    },

    otp: {
        type: String,
        default: null
    },
    otpVerified: {
        type: Boolean,
        default: false
    },
    otpExpiresAt: {
        type: Date,
        default: null
    },

    refreshToken: {
        type: String,
        default: null
    },
    refreshTokenExpiresAt: {
        type: Date,
        default: null
    },

    isAdmin: {
        type: Boolean,
        default: false
    },

    profile: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Profile",
        default: null
    },
    connections: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "User",
        default: []
    },
    eventsAttended: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "Events",
        default: []
    },
    posts: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "Posts",
        default: []
    },
    transactions: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "Transaction",
        default: []
    },
    subscription: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Subscription",
        default: null
    }
}, {
    timestamps: true
});

userSchema.pre('save', async function (next) {
    if (!this.isModified('mpin')) return next();

    try {
        const salt = await bcrypt.genSalt(env.security.bcryptRounds);
        this.mpin = await bcrypt.hash(this.mpin, salt);
        next();
    } catch (error) {
        next(error);
    }
});

userSchema.methods.compareMpin = async function (candidateMpin) {
    return bcrypt.compare(candidateMpin, this.mpin);
};

const User = mongoose.model("User", userSchema);

export default User; 