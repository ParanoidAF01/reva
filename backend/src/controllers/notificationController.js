import Notification from "../models/notification.js";
import User from "../models/user.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

const createNotification = asyncHandler(async (req, res) => {
    const { recipientId, type, title, message, route } = req.body;
    const senderId = req.user._id;

    if (!recipientId || !type || !title || !message || !route) {
        throw new ApiError(400, "All fields are required");
    }

    const recipient = await User.findById(recipientId);
    if (!recipient) {
        throw new ApiError(404, "Recipient not found");
    }

    const notification = await Notification.create({
        recipient: recipientId,
        sender: senderId,
        type,
        title,
        message,
        route
    });

    const populatedNotification = await Notification.findById(notification._id)
        .populate('recipient', 'fullName email')
        .populate('sender', 'fullName email');

    return res.status(201).json(
        new ApiResponse(201, populatedNotification, "Notification created successfully")
    );
});

const getMyNotifications = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { page = 1, limit = 10, type, isRead } = req.query;

    const query = { recipient: userId };

    if (type) {
        query.type = type;
    }

    if (isRead !== undefined) {
        query.isRead = isRead === 'true';
    }

    const notifications = await Notification.find(query)
        .populate({
            path: 'sender',
            select: 'fullName email status',
            populate: {
                path: 'profile',
                select: 'profilePicture'
            }
        })
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Notification.countDocuments(query);

    const unreadCount = await Notification.countDocuments({
        recipient: userId,
        isRead: false
    });

    return res.status(200).json(
        new ApiResponse(200, {
            notifications,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            totalNotifications: count,
            unreadCount
        }, "Notifications retrieved successfully")
    );
});

const getNotificationById = asyncHandler(async (req, res) => {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findById(notificationId)
        .populate('recipient', 'fullName email')
        .populate({
            path: 'sender',
            select: 'fullName email status',
            populate: {
                path: 'profile',
                select: 'profilePicture'
            }
        });

    if (!notification) {
        throw new ApiError(404, "Notification not found");
    }

    if (notification.recipient._id.toString() !== userId.toString()) {
        throw new ApiError(403, "Access denied");
    }

    return res.status(200).json(
        new ApiResponse(200, notification, "Notification retrieved successfully")
    );
});

const markAsRead = asyncHandler(async (req, res) => {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findById(notificationId);
    if (!notification) {
        throw new ApiError(404, "Notification not found");
    }

    if (notification.recipient.toString() !== userId.toString()) {
        throw new ApiError(403, "Access denied");
    }

    const updatedNotification = await Notification.findByIdAndUpdate(
        notificationId,
        { isRead: true },
        { new: true }
    ).populate({
        path: 'sender',
        select: 'fullName email status',
        populate: {
            path: 'profile',
            select: 'profilePicture'
        }
    });

    return res.status(200).json(
        new ApiResponse(200, updatedNotification, "Notification marked as read")
    );
});

const markAllAsRead = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    await Notification.updateMany(
        { recipient: userId, isRead: false },
        { isRead: true }
    );

    return res.status(200).json(
        new ApiResponse(200, {}, "All notifications marked as read")
    );
});

const deleteNotification = asyncHandler(async (req, res) => {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findById(notificationId);
    if (!notification) {
        throw new ApiError(404, "Notification not found");
    }

    if (notification.recipient.toString() !== userId.toString()) {
        throw new ApiError(403, "Access denied");
    }

    await Notification.findByIdAndDelete(notificationId);

    return res.status(200).json(
        new ApiResponse(200, {}, "Notification deleted successfully")
    );
});

const deleteAllNotifications = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    await Notification.deleteMany({ recipient: userId });

    return res.status(200).json(
        new ApiResponse(200, {}, "All notifications deleted successfully")
    );
});

const sendSystemNotification = asyncHandler(async (req, res) => {
    const { recipientIds, title, message, route = 'system' } = req.body;
    const senderId = req.user._id;

    if (!recipientIds || !Array.isArray(recipientIds) || recipientIds.length === 0) {
        throw new ApiError(400, "Recipient IDs array is required");
    }

    if (!title || !message) {
        throw new ApiError(400, "Title and message are required");
    }

    const notifications = [];
    for (const recipientId of recipientIds) {
        const recipient = await User.findById(recipientId);
        if (recipient) {
            const notification = await Notification.create({
                recipient: recipientId,
                sender: senderId,
                type: 'system_notification',
                title,
                message,
                route
            });
            notifications.push(notification);
        }
    }

    return res.status(201).json(
        new ApiResponse(201, { notifications }, "System notifications sent successfully")
    );
});

const sendEventNotification = asyncHandler(async (req, res) => {
    const { eventId, eventTitle, recipientIds, type, message } = req.body;
    const senderId = req.user._id;

    if (!eventId || !eventTitle || !recipientIds || !type || !message) {
        throw new ApiError(400, "All fields are required");
    }

    if (!Array.isArray(recipientIds) || recipientIds.length === 0) {
        throw new ApiError(400, "Recipient IDs array is required");
    }

    const notifications = [];
    for (const recipientId of recipientIds) {
        const recipient = await User.findById(recipientId);
        if (recipient) {
            const notification = await Notification.create({
                recipient: recipientId,
                sender: senderId,
                type,
                title: `Event: ${eventTitle}`,
                message,
                route: 'event'
            });
            notifications.push(notification);
        }
    }

    return res.status(201).json(
        new ApiResponse(201, { notifications }, "Event notifications sent successfully")
    );
});

const getNotificationStats = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const totalNotifications = await Notification.countDocuments({ recipient: userId });
    const unreadNotifications = await Notification.countDocuments({
        recipient: userId,
        isRead: false
    });
    const readNotifications = totalNotifications - unreadNotifications;

    const typeStats = await Notification.aggregate([
        { $match: { recipient: userId } },
        { $group: { _id: '$type', count: { $sum: 1 } } }
    ]);

    return res.status(200).json(
        new ApiResponse(200, {
            total: totalNotifications,
            unread: unreadNotifications,
            read: readNotifications,
            typeStats
        }, "Notification statistics retrieved successfully")
    );
});

export {
    createNotification,
    getMyNotifications,
    getNotificationById,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    deleteAllNotifications,
    sendSystemNotification,
    sendEventNotification,
    getNotificationStats
}; 