import Notification from "../models/notification.js";
// import { logger } from "./logger.js";

const createNotificationHelper = async (recipientId, senderId, type, title, message, route) => {
    try {
        const notification = await Notification.create({
            recipient: recipientId,
            sender: senderId,
            type,
            title,
            message,
            route
        });

        // logger.info(`Notification created: ${type} for user ${recipientId}`);
        return notification;
    } catch (error) {
        // logger.error(`Error creating notification: ${error.message}`);
        throw error;
    }
};

export const sendConnectionRequestNotification = async (recipientId, senderId, senderName) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'connection_request',
        'New Connection Request',
        `${senderName} wants to connect with you`,
        'connection'
    );
};

export const sendConnectionAcceptedNotification = async (recipientId, senderId, senderName) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'connection_accepted',
        'Connection Accepted',
        `${senderName} accepted your connection request`,
        'connection'
    );
};

export const sendConnectionRemovedNotification = async (recipientId, senderId, senderName) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'connection_removed',
        'Connection Removed',
        `${senderName} removed you from their connections`,
        'connection'
    );
};

export const sendPostLikeNotification = async (recipientId, senderId, senderName, postTitle) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'post_like',
        'New Like on Your Post',
        `${senderName} liked your post: "${postTitle}"`,
        'post'
    );
};

export const sendPostCommentNotification = async (recipientId, senderId, senderName, postTitle) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'post_comment',
        'New Comment on Your Post',
        `${senderName} commented on your post: "${postTitle}"`,
        'post'
    );
};

export const sendPostShareNotification = async (recipientId, senderId, senderName, postTitle) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'post_share',
        'Post Shared',
        `${senderName} shared your post: "${postTitle}"`,
        'post'
    );
};

export const sendPostMentionNotification = async (recipientId, senderId, senderName, postTitle) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'mention',
        'You Were Mentioned',
        `${senderName} mentioned you in a post: "${postTitle}"`,
        'post'
    );
};

export const sendEventInvitationNotification = async (recipientId, senderId, senderName, eventTitle) => {
    return await createNotificationHelper(
        recipientId,
        senderId,
        'event_invitation',
        'Event Invitation',
        `${senderName} invited you to: "${eventTitle}"`,
        'event'
    );
};

export const sendEventReminderNotification = async (recipientId, eventTitle, eventDate) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'event_reminder',
        'Event Reminder',
        `Reminder: "${eventTitle}" is starting soon on ${eventDate}`,
        'event'
    );
};

export const sendEventUpdateNotification = async (recipientId, eventTitle, updateType) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'event_update',
        'Event Updated',
        `The event "${eventTitle}" has been ${updateType}`,
        'event'
    );
};

export const sendEventCancellationNotification = async (recipientId, eventTitle) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'event_cancelled',
        'Event Cancelled',
        `The event "${eventTitle}" has been cancelled`,
        'event'
    );
};

export const sendWalletTransactionNotification = async (recipientId, transactionType, amount) => {
    const title = transactionType === 'credit' ? 'Money Received' : 'Money Sent';
    const message = transactionType === 'credit'
        ? `You received ₹${amount} in your wallet`
        : `You sent ₹${amount} from your wallet`;

    return await createNotificationHelper(
        recipientId,
        null,
        'wallet_transaction',
        title,
        message,
        'transaction'
    );
};

export const sendWalletLowBalanceNotification = async (recipientId, currentBalance) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'wallet_low_balance',
        'Low Wallet Balance',
        `Your wallet balance is low: ₹${currentBalance}`,
        'transaction'
    );
};

export const sendSubscriptionUpdateNotification = async (recipientId, subscriptionType, status) => {
    const title = status === 'active' ? 'Subscription Activated' : 'Subscription Updated';
    const message = `Your ${subscriptionType} subscription has been ${status}`;

    return await createNotificationHelper(
        recipientId,
        null,
        'subscription_update',
        title,
        message,
        'subscription'
    );
};

export const sendSubscriptionExpiryNotification = async (recipientId, subscriptionType, expiryDate) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'subscription_expiry',
        'Subscription Expiring Soon',
        `Your ${subscriptionType} subscription expires on ${expiryDate}`,
        'subscription'
    );
};

export const sendNFCCardCreatedNotification = async (recipientId, cardType) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'nfc_card_created',
        'NFC Card Created',
        `Your ${cardType} NFC card has been created successfully`,
        'nfc_card'
    );
};

export const sendNFCCardScannedNotification = async (recipientId, scannerName) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'nfc_card_scanned',
        'NFC Card Scanned',
        `${scannerName} scanned your NFC card`,
        'nfc_card'
    );
};

export const sendSystemNotification = async (recipientId, title, message) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'system_notification',
        title,
        message,
        'system'
    );
};

export const sendWelcomeNotification = async (recipientId, userName) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'welcome',
        'Welcome to Reva!',
        `Welcome ${userName}! We're excited to have you on board.`,
        'system'
    );
};

export const sendProfileUpdateNotification = async (recipientId, updateType) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'profile_update',
        'Profile Updated',
        `Your ${updateType} has been updated successfully`,
        'profile'
    );
};

export const sendBulkNotifications = async (recipientIds, senderId, type, title, message, route) => {
    const notifications = [];

    for (const recipientId of recipientIds) {
        try {
            const notification = await createNotificationHelper(
                recipientId,
                senderId,
                type,
                title,
                message,
                route
            );
            notifications.push(notification);
        } catch (error) {
            // logger.error(`Failed to send notification to ${recipientId}: ${error.message}`);
        }
    }

    return notifications;
};

export const sendAnnouncementNotification = async (recipientIds, title, message) => {
    return await sendBulkNotifications(
        recipientIds,
        null,
        'announcement',
        title,
        message,
        'system'
    );
};

export const sendErrorNotification = async (recipientId, operation, errorMessage) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'error_notification',
        'Operation Failed',
        `Failed to ${operation}: ${errorMessage}`,
        'system'
    );
};

export const sendSuccessNotification = async (recipientId, operation) => {
    return await createNotificationHelper(
        recipientId,
        null,
        'success_notification',
        'Operation Successful',
        `${operation} completed successfully`,
        'system'
    );
};

export default {
    sendConnectionRequestNotification,
    sendConnectionAcceptedNotification,
    sendConnectionRemovedNotification,

    sendPostLikeNotification,
    sendPostCommentNotification,
    sendPostShareNotification,
    sendPostMentionNotification,

    sendEventInvitationNotification,
    sendEventReminderNotification,
    sendEventUpdateNotification,
    sendEventCancellationNotification,

    sendWalletTransactionNotification,
    sendWalletLowBalanceNotification,

    sendSubscriptionUpdateNotification,
    sendSubscriptionExpiryNotification,

    sendNFCCardCreatedNotification,
    sendNFCCardScannedNotification,

    sendSystemNotification,
    sendWelcomeNotification,
    sendProfileUpdateNotification,

    sendBulkNotifications,
    sendAnnouncementNotification,

    sendErrorNotification,
    sendSuccessNotification
}; 