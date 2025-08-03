import mongoose from "mongoose";

const subscriptionSchema = mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    plan: {
        type: String,
        enum: ['annual', 'trial', 'monthly'],
        default: 'annual'
    },
    amountPaid: {
        type: Number,
        required: true,
        min: 0
    },
    status: {
        type: String,
        enum: ['active', 'cancelled', 'expired', 'pending'],
        default: 'pending'
    },
    startDate: {
        type: Date,
        required: true
    },
    endDate: {
        type: Date,
        required: true
    },
    autoRenew: {
        type: Boolean,
        default: false
    },
    paymentMethod: {
        type: String,
        enum: ['wallet', 'card', 'upi', 'net_banking'],
        required: true
    },
    cancellationDate: {
        type: Date
    },
    cancellationReason: {
        type: String
    }
}, {
    timestamps: true
});

const Subscription = mongoose.model("Subscription", subscriptionSchema);

export default Subscription; 