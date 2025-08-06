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
        minlength: 1
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

    status: {
        type: String,
        enum: ['bronze', 'silver', 'gold'],
        default: 'bronze'
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
    if (!this.isModified('mpin') || !this.mpin) return next();

    if (!this.mpin || typeof this.mpin !== 'string' || this.mpin.length < 1) {
        return next(new Error('MPIN is required'));
    }

    try {
        // Ensure rounds is a number
        const rounds = Number(env.security.bcryptRounds) || 12;
        const salt = await bcrypt.genSalt(rounds);
        this.mpin = await bcrypt.hash(this.mpin, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Method to update user status based on connections count
userSchema.methods.updateStatus = function () {
    const connectionsCount = this.connections.length;

    if (connectionsCount >= 1000) {
        this.status = 'gold';
    } else if (connectionsCount >= 500) {
        this.status = 'silver';
    } else {
        this.status = 'bronze';
    }

    return this.status;
};

userSchema.methods.compareMpin = async function (candidateMpin) {
    return bcrypt.compare(candidateMpin, this.mpin);
};

const User = mongoose.model("User", userSchema);

export default User; 