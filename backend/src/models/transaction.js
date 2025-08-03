import mongoose from "mongoose";

const transactionSchema = mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    type: {
        type: String,
        enum: ['credit', 'debit'],
        required: true
    },
    amount: {
        type: Number,
        required: true,
        min: 0
    },
    category: {
        type: String,
        enum: ['event_payment', 'subscription', 'refund', 'transfer', 'withdrawal', 'deposit', 'other'],
        default: 'other'
    },
    status: {
        type: String,
        enum: ['pending', 'completed', 'failed', 'cancelled'],
        default: 'pending'
    },
    paymentMethod: {
        type: String,
        enum: ['wallet', 'card', 'upi', 'net_banking', 'cash'],
        default: 'wallet'
    }
}, {
    timestamps: true
});


const Transaction = mongoose.model("Transaction", transactionSchema);

export default Transaction; 