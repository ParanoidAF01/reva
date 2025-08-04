import mongoose from "mongoose";

const nfcCardSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    cardNumber: {
        type: String,
        unique: true,
    },
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected', 'active', 'inactive'],
        default: 'pending'
    },
    requestType: {
        type: String,
        enum: ['new', 'replacement', 'upgrade'],
        required: true,
        default: 'new'
    },
    requestDate: {
        type: Date,
        default: Date.now
    },
    cardLeague: {
        type: String,
        enum: ['bronze', 'silver', 'gold'],
        default: 'bronze'
    }
}, {
    timestamps: true
});

nfcCardSchema.pre('save', async function (next) {
    if (this.isNew && !this.cardNumber) {
        const timestamp = Date.now().toString();
        const random = Math.random().toString(36).substring(2, 8);
        this.cardNumber = `NFC${timestamp}${random}`.toUpperCase();
    }
    next();
});

const NFCCard = mongoose.model("NFCCard", nfcCardSchema);

export default NFCCard; 