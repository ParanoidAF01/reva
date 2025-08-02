import mongoose from "mongoose";

const notificationSchema = mongoose.Schema({
    recipient: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Users",
        required: true
    },
    sender: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Users"
    },
    type: {
        type: String,
        enum: [
            'connection_request',
            'connection_accepted',
            'event_invitation',
            'event_reminder',
            'post_like',
            'post_comment',
            'post_share',
            'wallet_transaction',
            'subscription_update',
            'system_notification',
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
        enum: ['event', 'post', 'transaction', 'subscription', 'system', 'message', 'mention'],
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