import mongoose from "mongoose";

const notificationSchema = mongoose.Schema({
    recipient: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    sender: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
    },
    type: {
        type: String,
        enum: [
            'connection_request',
            'connection_accepted',
            'connection_removed',
            'event_invitation',
            'event_reminder',
            'event_update',
            'event_cancelled',
            'post_like',
            'post_comment',
            'post_share',
            'wallet_transaction',
            'wallet_low_balance',
            'subscription_update',
            'subscription_expiry',
            'nfc_card_created',
            'nfc_card_scanned',
            'system_notification',
            'welcome',
            'profile_update',
            'announcement',
            'error_notification',
            'success_notification',
            'message',
            'mention'
        ],
        required: true
    },
    title: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    route: {
        type: String,
        enum: ['event', 'post', 'transaction', 'subscription', 'system', 'message', 'mention', 'connection', 'profile', 'nfc_card'],
        required: true
    },
    isRead: {
        type: Boolean,
        default: false
    }
}, {
    timestamps: true
});

const Notification = mongoose.model("Notification", notificationSchema);

export default Notification; 